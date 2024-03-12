<?php
// Connect to the database
$mysqli = new mysqli("localhost", "atbRoot", "M4g4ll4nes.24", "atb_sf");

// Check connection
if ($mysqli->connect_error) {
    http_response_code(500); // Internal Server Error
    echo json_encode(["error" => "Connection failed: " . $mysqli->connect_error]);
    exit;
}

// Determine the type of operation from the request
$data = json_decode(file_get_contents('php://input'), true);
if (!$data || !isset($data['operation'])) {
    http_response_code(400); // Bad Request
    echo json_encode(["error" => "Missing operation field"]);
    exit;
}

switch ($data['operation']) {
    case 'I': // Insert operation
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
            echo json_encode(["error" => "Missing required fields for insert operation"]);
        }
        break;
    
    case 'U': // Update operation
        if (isset($data['loanId'], $data['amount'])) {
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
        break;

    case 'D': // Delete operation
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
            echo json_encode(["error" => "Missing required field for delete operation"]);
        }
        break;

    default:
        http_response_code(400); // Bad Request
        echo json_encode(["error" => "Invalid operation specified"]);
        break;
}
?>
