CREATE TABLE operations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    loanId VARCHAR(100) NOT NULL,
    accountNumber VARCHAR(100) NOT NULL,
    amount DECIMAL(16, 2) NOT NULL,
    operationType ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
