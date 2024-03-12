
text/x-generic update_loan.php ( PHP script text )

<?php
// Connect to the database
$mysqli = new mysqli("localhost", "username", "password", "db_name");

// Check connection
if ($mysqli->connect_error) {
    http_response_code(500); // Internal Server Error
    echo json_encode(["error" => "Connection failed: " . $mysqli->connect_error]);
    exit;
}

// Update operation
if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    $data = json_decode(file_get_contents('php://input'), true);
    if (isset($data['loanId'], $data['amount'])) {
        $loanId = $mysqli->real_escape_string($data['loanId']);
        $amount = $mysqli->real_escape_string($data['amount']);

        $sql = "UPDATE operations SET amount = '$amount' WHERE loanId = '$loanId'";

        if ($mysqli->query($sql) === TRUE) {
            if ($mysqli->affected_rows > 0) {
                echo json_encode(["message" => "Loan updated successfully"]);
            } else {
                http_response_code(404); // Not Found
                echo json_encode(["error" => "Loan does not exist"]);
            }
        } else {
            http_response_code(500); // Internal Server Error
            echo json_encode(["error" => "Error updating loan"]);
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

