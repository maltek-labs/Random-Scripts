import base64


with open('encrypted.txt', 'rb') as r:
    data = r.read()
r.close()


XOR_Range = range(1, 255)
Decoded_String = []
Decode_B64_data = base64.decodebytes(data)

for xor in XOR_Range:
    for char in Decode_B64_data:
            XOR_Char = xor^char
            Decoded_String.append(chr(XOR_Char))
            
            string = ''.join(Decoded_String)
            string = f'{string}\n\n\n\n'

    with open('Decrypted_Text.txt', 'a', errors='ignore') as a:
        a.write(string)
    a.close()

    Decoded_String.clear()
    string = ''
