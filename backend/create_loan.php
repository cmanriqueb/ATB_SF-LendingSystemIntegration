
text/x-generic create_loan.php ( PHP script text )

<?php
// Connect to the database
$mysqli = new mysqli("localhost", "username", "password", "db_name");

// Check connection
if ($mysqli->connect_error) {
    http_response_code(500); // Internal Server Error
    echo json_encode(["error" => "Connection failed: " . $mysqli->connect_error]);
    exit;
}

// Insert operation
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    if (isset($data['accountNumber'], $data['amount'])) {
        $accountNumber = $mysqli->real_escape_string($data['accountNumber']);
        $amount = $mysqli->real_escape_string($data['amount']);
        $loanId = 'loan-' . $accountNumber;

        $sql = "INSERT INTO operations (loanId, accountNumber, amount) VALUES ('$loanId', '$accountNumber', '$amount')";

        if ($mysqli->query($sql) === TRUE) {
            echo json_encode(["loanId" => $loanId]);
        } else {
            http_response_code(500); // Internal Server Error
            echo json_encode(["error" => "Error creating loan"]);
        }
    } else {
        http_response_code(400); // Bad Request
        echo json_encode(["error" => "Missing required fields"]);
    }
} else {
    http_response_code(405); // Method Not Allowed
    echo json_encode(["error" => "Invalid request method"]);
}
?>

