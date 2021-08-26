#include <stdint.h>

struct EncryptionResult {
    int length;
    uint8_t* data;
    void (*freePtr)(uint8_t* data);
};

EncryptionResult encrypt(char* key, int size, uint8_t* data);
EncryptionResult decrypt(char* key, int size, uint8_t* data);