
text/x-generic delete_loan.php ( PHP script text )

<?php
// Connect to the database
$mysqli = new mysqli("localhost", "username", "password", "dn_name");

// Check connection
if ($mysqli->connect_error) {
    http_response_code(500); // Internal Server Error
    echo json_encode(["error" => "Connection failed: " . $mysqli->connect_error]);
    exit;
}

// Delete operation
if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    $data = json_decode(file_get_contents('php://input'), true);
    if (isset($data['loanId'])) {
        $loanId = $mysqli->real_escape_string($data['loanId']);

        $sql = "DELETE FROM operations WHERE loanId = '$loanId'";

        if ($mysqli->query($sql) === TRUE) {
            if ($mysqli->affected_rows > 0) {
                echo json_encode(["message" => "Loan deleted successfully"]);
            } else {
                http_response_code(404); // Not Found
                echo json_encode(["error" => "Loan does not exist"]);
            }
        } else {
            http_response_code(500); // Internal Server Error
            echo json_encode(["error" => "Error deleting loan"]);
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

