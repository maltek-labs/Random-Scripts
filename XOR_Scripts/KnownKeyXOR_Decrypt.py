import binascii

        ################################################################
        # Original Decompiled code
'''
        char * __cdecl F_XOR_Decrypt(char *p_DataToDecrypt)

        {
        size_t Len(DataToDecrypt);
        char *ArrayOfData;
        uint Index;
        uint Index_DataToDecrypt;

        Len(DataToDecrypt) = _strlen(p_DataToDecrypt);
        ArrayOfData = (char *)_malloc(Len(DataToDecrypt) + 1);
        FID_conflict:__mbscpy(ArrayOfData,p_DataToDecrypt);
        Index_DataToDecrypt = 0;
        while( true ) {
            Len(DataToDecrypt) = _strlen(ArrayOfData);
            if (Len(DataToDecrypt) <= Index_DataToDecrypt) break;
            for (Index = 0; Index < 9; Index = Index + 1) {
            ArrayOfData[Index_DataToDecrypt] = ArrayOfData[Index_DataToDecrypt] ^ DecryptionKey[Index];
            }
                            /* Decyption Key in order: 75 69 7a 68 32 39 38 34 00
                            Location: 0x00413bfc */
            if (_DAT_00413c08 != 0) {
            ArrayOfData[Index_DataToDecrypt] = ~ArrayOfData[Index_DataToDecrypt];
            }
            Index_DataToDecrypt = Index_DataToDecrypt + 1;
        }
        return ArrayOfData;
        }

'''
        ################################################################

def DecryptXOR():
    DecryptionKey = '75 69 7a 68 32 39 38 34 00'.split(' ')
    HEX_list = []
    Decoded_Data = []
    Decoded_List = []

    with open('XOR_Data.txt', 'r') as r:
        EncryptedData = r.readlines()

    for item in EncryptedData:
        DataToDecrypt = item.split(' ')
        
        #############################
        # Data Clean up
        for NewLine in DataToDecrypt:
            HEX_list.append(NewLine.strip())

        NullByte = '00'
        while NullByte in HEX_list:
            HEX_list.remove(NullByte)
        #############################
        
        # Decryption Routine for XOR. Accepts any amount of known XOR keys and XORs each Hex value in sequence. 
        for char in HEX_list:
            ascii_value = ord(binascii.a2b_hex(bytearray(char, 'ascii')))

            for xor in DecryptionKey:
                xor_value = ord(binascii.a2b_hex(bytearray(xor, 'ascii')))
                Decoded_Value = ascii_value ^ xor_value
                ascii_value = Decoded_Value

                # Binary bitwise NOT operation converted to python. 
                if xor == DecryptionKey[-1]: 
                    Binary_Dict = {'0': '1', '1': '0'}
                    BitsToSwitch = str(bin(Decoded_Value))[2:]
                    Bit_String = ''
                    
                    for i in BitsToSwitch:
                        Bit_String += Binary_Dict[i]

                    Decoded_Data.append(chr(int(Bit_String, 2)))

        # After Decryption Cleanup.    
        Decoded_String = ''.join(Decoded_Data)
        Decoded_List.append(Decoded_String)
        Decoded_Data.clear()
        HEX_list.clear()
            
    for item in Decoded_List:
        with open('Decoded_Data.txt', 'a') as a:
            a.write(f'{item}\n')

DecryptXOR()