#include <string>
#include <vector>

#include <windows.h>

#include <Intsafe.h>

#include <iostream>
#include <map>
#include <memory>
#include <sstream>

#include "crypto.h"

#define BLOCK_SIZE 32

int main() {
    return 0;
}

void freeEncrypt(uint8_t* data) {
    if (data == nullptr) {
        return;
    }

    free(data);
}

void _printHash(HCRYPTHASH hHash) {
    BYTE hash[32];
    memset(hash, 0, 32);
    DWORD len = 32;

    if (!CryptGetHashParam(hHash, HP_HASHVAL, hash, &len, 0)) {
        printf("Error getting hash: %x\n", GetLastError());
        return;
    }

    printf("Hashed data: ");
    for (int i = 0; i < 32; i++) {
        printf("%x, ", hash[i]);
    }
    printf("\n");
}

boolean _deriveKey(HCRYPTPROV hProv, HCRYPTKEY* hKey, std::string input) {
    HCRYPTHASH hHash;

    if (!CryptCreateHash(hProv, CALG_SHA_256, 0, 0, &hHash)) {
        printf("Error creating hash: %x\n", GetLastError());
        return false;
    }

    DWORD keyLen = input.length();
    if (!CryptHashData(hHash, (BYTE*)input.c_str(), keyLen, 0)) {
        printf("Error hashing: %x\n", GetLastError());
        CryptDestroyHash(hHash);
        return false;
    }

    // _printHash(hHash);

    if (!CryptDeriveKey(hProv, CALG_AES_256, hHash, 0, hKey)) {
        CryptDestroyHash(hHash);
        return false;
    }

    return true;
}

boolean _encrypt(std::string key, std::vector<uint8_t> data, std::vector<uint8_t>* out) {
    wchar_t info[] = L"Microsoft Enhanced RSA and AES Cryptographic Provider";

    HCRYPTPROV hProv;
    if (!CryptAcquireContextW(&hProv, NULL, info, PROV_RSA_AES, CRYPT_VERIFYCONTEXT)) {
        CryptReleaseContext(hProv, 0);
        return false;
    }

    HCRYPTKEY hKey;
    if (!_deriveKey(hProv, &hKey, key)) {
        CryptReleaseContext(hProv, 0);
        return false;
    }

    uint8_t* bytes = data.data();
    DWORD length = data.size();
    uint8_t buffer[BLOCK_SIZE];
    int current = 0;

    while (current < length) {
        boolean isFinal = current + BLOCK_SIZE >= length;
        DWORD currentLen = isFinal ? length - current : BLOCK_SIZE;

        memset(buffer, 0, BLOCK_SIZE);
        memcpy(buffer, &data[current], currentLen);

        if (!CryptEncrypt(hKey, NULL, isFinal, 0, buffer, &currentLen, BLOCK_SIZE)) {
            DWORD error = GetLastError();
            printf("Error encrypting: %d (0x%x)\n", error, error);

            return false;
        }

        for (int i = 0; i < currentLen; i++) {
            out->push_back(buffer[i]);
        }

        current += BLOCK_SIZE;
    }

    CryptReleaseContext(hProv, 0);
    CryptDestroyKey(hKey);

    return true;
}

boolean _decrypt(std::string key, std::vector<uint8_t> data, std::vector<uint8_t>* out) {
    wchar_t info[] = L"Microsoft Enhanced RSA and AES Cryptographic Provider";

    HCRYPTPROV hProv;
    if (!CryptAcquireContextW(&hProv, NULL, info, PROV_RSA_AES, CRYPT_VERIFYCONTEXT)) {
        CryptReleaseContext(hProv, 0);
        return false;
    }

    HCRYPTKEY hKey;
    if (!_deriveKey(hProv, &hKey, key)) {
        CryptReleaseContext(hProv, 0);
        return false;
    }

    uint8_t* bytes = data.data();
    DWORD length = data.size();
    uint8_t buffer[BLOCK_SIZE];
    int current = 0;

    while (current < length) {
        boolean isFinal = current + BLOCK_SIZE >= length;
        DWORD currentLen = isFinal ? length - current : BLOCK_SIZE;

        memset(buffer, 0, BLOCK_SIZE);
        memcpy(buffer, &data[current], currentLen);

        if (!CryptDecrypt(hKey, NULL, isFinal, 0, buffer, &currentLen)) {
            DWORD error = GetLastError();
            printf("Error decrypting: %d (0x%x)\n", error, error);

            return false;
        }

        for (int i = 0; i < currentLen; i++) {
            out->push_back(buffer[i]);
        }

        current += BLOCK_SIZE;
    }

    CryptReleaseContext(hProv, 0);
    CryptDestroyKey(hKey);

    return true;
}

EncryptionResult encrypt(char* key, uint8_t* data, int dataLen) {
    std::string keyStr = std::string(key);
    std::vector<uint8_t> dataVector = std::vector<uint8_t>(data, data + dataLen);

    std::vector<uint8_t>* encrypted = new std::vector<uint8_t>();
    boolean result = _encrypt(keyStr, dataVector, encrypted);

    if (!result) {
        return {
            -1,
            0,
            &freeEncrypt,
        };
    }

    uint8_t* out = (uint8_t*)malloc(encrypted->size());
    memcpy(out, encrypted->data(), encrypted->size());

    return {
        (int)encrypted->size(),
        out,
        &freeEncrypt,
    };
}

EncryptionResult decrypt(char* key, uint8_t* data, int dataLen) {
    std::string keyStr = std::string(key);
    std::vector<uint8_t> dataVector = std::vector<uint8_t>(data, data + dataLen);

    std::vector<uint8_t>* decrypted = new std::vector<uint8_t>();
    boolean result = _decrypt(keyStr, dataVector, decrypted);

    if (!result) {
        return {
            -1,
            0,
            &freeEncrypt,
        };
    }

    uint8_t* out = (uint8_t*)malloc(decrypted->size());
    memcpy(out, decrypted->data(), decrypted->size());

    return {
        (int)decrypted->size(),
        out,
        &freeEncrypt,
    };
}