## 39. Column-Level Encryption  
**Purpose:**  
Enhance data security by encrypting sensitive data stored in specific columns. This protects data at rest and limits exposure if unauthorized access occurs.

**Example (SQL Server using symmetric key encryption):**  
```sql
-- First, open the symmetric key (configured previously with a certificate)
OPEN SYMMETRIC KEY MyKey DECRYPTION BY CERTIFICATE MyCert;

-- Encrypt the SSN column for a specific customer
UPDATE Customers 
SET EncryptedSSN = ENCRYPTBYKEY(KEY_GUID('MyKey'), SSN)
WHERE CustomerID = 123;
```

*This example encrypts the `SSN` field into a new column `EncryptedSSN`. Decryption would use the corresponding DECRYPTBYKEY function.*