#!/bin/bash

echo MYSQL_SERVER_IP=${mysql_server_ip} >> /etc/environment

echo "Setup of backendserver VM has begun.">/var/log/user.log

apt-get update
apt-get install -y apache2 php libapache2-mod-php php-mysql

# Create back-index.php file
cat << EOF > /var/www/html/back-index.php
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>

<head>
    <title>Manage Bookmarks</title>
    <link rel="stylesheet" href="backstyle.css">
</head>

<body>
    <h1>Manage Your Bookmarks</h1>

    <h2>Overview of Current Bookmarks</h2>

    <?php
    \$serverhost = "${mysql_server_ip}";
    \$dbname = '${db_name}';
    \$username = '${db_username}';
    \$password = '${db_password}';

     // Create connection
    \$conn = new mysqli(\$serverhost, \$username, \$password, \$dbname);

    // Check connection
    if (\$conn->connect_error) {
        die("Connection failed: " . \$conn->connect_error);
    }

    // Query to fetch bookmarks with associated tags
    \$sql = "
        SELECT b.bookmark_id, b.url, b.title, b.description, GROUP_CONCAT(t.tag_name SEPARATOR ', ') AS tags
        FROM bookmarks b
        LEFT JOIN bookmark_tags bt ON b.bookmark_id = bt.bookmark_id
        LEFT JOIN tags t ON bt.tag_id = t.tag_id
        GROUP BY b.bookmark_id
        ";
    \$result = \$conn->query(\$sql);

    if (\$result->num_rows > 0) {
        echo "<table>";
        echo "<tr><th>Title</th><th>URL</th><th>Description</th><th>Tags</th><th>Actions</th></tr>";

        // Output data of each row
        while (\$row = \$result->fetch_assoc()) {
            echo "<tr>";
            echo "<td>" . htmlspecialchars(\$row["title"]) . "</td>";
            echo "<td><a href='" . htmlspecialchars(\$row["url"]) . "' target='_blank'>" . htmlspecialchars(\$row["url"]) . "</a></td>";
            echo "<td>" . htmlspecialchars(\$row["description"]) . "</td>";
            echo "<td>" . htmlspecialchars(\$row["tags"]) . "</td>";
            echo "<td>
                <a class='t-btn' href='back-edit.php?edit=" . \$row['bookmark_id'] . "'>Edit</a> |
                <a class='t-btn' href='back-edit.php?delete=" . \$row['bookmark_id'] . "' onclick='return confirm(\"Are you sure you want to delete this bookmark?\");'>Delete</a>
                </td>";
            echo "</tr>";
        }

        echo "</table>";
    } else {
        echo "<p>No bookmarks found.</p>";
    }

    // Close connection
    \$conn->close();
    ?>

    <!-- button which redirects to form to add new bookmark -->
    <form class="form-btn" action="back-edit.php">
        <input class="submit-btn" type="submit" value="Add a bookmark" />
    </form>

    <a class="back-btn" href="http://test/front-index">←</a>
</body>

</html>
EOF

# Create back-edit.php file
cat << EOF > /var/www/html/back-edit.php
<?php
\$serverhost = "${mysql_server_ip}";
\$dbname = '${db_name}';
\$username = '${db_username}';
\$password = '${db_password}';

// Create connection
\$conn = new mysqli(\$serverhost, \$username, \$password, \$dbname);

// Check connection
if (\$conn->connect_error) {
    die("Connection failed: " . \$conn->connect_error);
}

// Handle insertion of a new bookmark
if (isset(\$_POST['add'])) {
    \$title = \$conn->real_escape_string(\$_POST['title']);
    \$url = \$conn->real_escape_string(\$_POST['url']);
    \$description = \$conn->real_escape_string(\$_POST['description']);
    \$tags = explode(',', \$_POST['tags']);

    // Insert into bookmarks table
    \$sql = "INSERT INTO bookmarks (title, url, description) VALUES ('\$title', '\$url', '\$description')";
    if (\$conn->query(\$sql) === TRUE) {
        \$bookmark_id = \$conn->insert_id;

        // Insert tags into tags table and link to bookmark
        foreach (\$tags as \$tag) {
            \$tag = trim(\$tag);
            \$tag_sql = "INSERT INTO tags (tag_name) VALUES ('\$tag') ON DUPLICATE KEY UPDATE tag_id=LAST_INSERT_ID(tag_id)";
            if (\$conn->query(\$tag_sql) === TRUE) {
                \$tag_id = \$conn->insert_id;
                \$conn->query("INSERT INTO bookmark_tags (bookmark_id, tag_id) VALUES ('\$bookmark_id', '\$tag_id')");
            }
        }

        // Redirect back to index.php
        header("Location: back-index.php");
        exit();
    }
}

// Handle deletion of a bookmark
if (isset(\$_GET['delete'])) {
    \$bookmark_id = intval(\$_GET['delete']);
    // Delete from bookmark_tags first (foreign key constraint)
    \$conn->query("DELETE FROM bookmark_tags WHERE bookmark_id = \$bookmark_id");
    // Then delete from bookmarks
    \$conn->query("DELETE FROM bookmarks WHERE bookmark_id = \$bookmark_id");

    // Redirect back to index.php
    header("Location: back-index.php");
    exit();
}

// Handle update of a bookmark
if (isset(\$_POST['update'])) {
    \$bookmark_id = intval(\$_POST['bookmark_id']);
    \$title = \$conn->real_escape_string(\$_POST['title']);
    \$url = \$conn->real_escape_string(\$_POST['url']);
    \$description = \$conn->real_escape_string(\$_POST['description']);
    \$tags = explode(',', \$_POST['tags']);

    // Update the bookmarks table
    \$sql = "UPDATE bookmarks SET title = '\$title', url = '\$url', description = '\$description' WHERE bookmark_id = \$bookmark_id";
    if (\$conn->query(\$sql) === TRUE) {
        // Delete existing tags for the bookmark
        \$conn->query("DELETE FROM bookmark_tags WHERE bookmark_id = \$bookmark_id");

        // Insert updated tags
        foreach (\$tags as \$tag) {
            \$tag = trim(\$tag);
            \$tag_sql = "INSERT INTO tags (tag_name) VALUES ('\$tag') ON DUPLICATE KEY UPDATE tag_id=LAST_INSERT_ID(tag_id)";
            if (\$conn->query(\$tag_sql) === TRUE) {
                \$tag_id = \$conn->insert_id;
                \$conn->query("INSERT INTO bookmark_tags (bookmark_id, tag_id) VALUES ('\$bookmark_id', '\$tag_id')");
            }
        }

        // Redirect back to index.php
        header("Location: back-index.php");
        exit();
    }
}

// If editing, retrieve the existing data
if (isset(\$_GET['edit'])) {
    \$bookmark_id = intval(\$_GET['edit']);
    \$result = \$conn->query("SELECT * FROM bookmarks WHERE bookmark_id = \$bookmark_id");

    if (\$result->num_rows > 0) {
        \$bookmark = \$result->fetch_assoc();
        \$title = \$bookmark['title'];
        \$url = \$bookmark['url'];
        \$description = \$bookmark['description'];

        // Retrieve the associated tags
        \$tags_result = \$conn->query("SELECT t.tag_name FROM tags t INNER JOIN bookmark_tags bt ON t.tag_id = bt.tag_id WHERE bt.bookmark_id = \$bookmark_id");
        \$tags = [];
        while (\$tag_row = \$tags_result->fetch_assoc()) {
            \$tags[] = \$tag_row['tag_name'];
        }
        \$tags = implode(', ', \$tags);
    }
}

\$conn->close();
?>

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>

<head>
    <title>Edit Bookmark</title>
    <link rel="stylesheet" href="backstyle.css">
</head>

<body>
    <h1><?php echo isset(\$bookmark_id) ? 'Edit Bookmark' : 'Add New Bookmark'; ?></h1>

    <form class="form-fields" method="post" action="back-edit.php">
        <input type="hidden" name="bookmark_id" value="<?php echo isset(\$bookmark_id) ? \$bookmark_id : ''; ?>">
        <p>
            <label class="label-txt">Title:</label>
            <input class="input-box" type="text" name="title" placeholder="Name" value="<?php echo isset(\$title) ? htmlspecialchars(\$title) : ''; ?>" required>
        </p>
        <p>
            <label class="label-txt">URL:</label>
            <input class="input-box" type="url" name="url" placeholder="URL" value="<?php echo isset(\$url) ? htmlspecialchars(\$url) : ''; ?>" required>
        </p>
        <p>
            <label class="label-txt">Description:</label>
            <textarea class="input-box" name="description" placeholder="Description" required><?php echo isset(\$description) ? htmlspecialchars(\$description) : ''; ?></textarea>
        </p>
        <p>
            <label class="label-txt">Tags (comma-separated):</label>
            <input class="input-box" type="text" name="tags" placeholder="Tags" value="<?php echo isset(\$tags) ? htmlspecialchars(\$tags) : ''; ?>">
        </p>
        <p>
            <input class="submit-btn" type="submit" name="<?php echo isset(\$bookmark_id) ? 'update' : 'add'; ?>" value="<?php echo isset(\$bookmark_id) ? 'Update Bookmark' : 'Add Bookmark'; ?>">
        </p>
    </form>

    <a class="back-btn" href="back-index.php">← Back to Bookmark List</a>
</body>

</html>
EOF

# Create backend styles file
cat << EOF > /var/www/html/backstyle.css
body {
    font-family: Arial, sans-serif;
    background-color: #f4f4f9;
    margin: 0;
    padding: 20px;

    /* text-align: center; */
}

h1 {
    color: #333;
    text-align: center;
    font-size: 50px;
    margin-top: 20px;
    margin-bottom: 20px;
    /* margin-bottom: 40px; */
}

h2 {
    color: #333;
    text-align: center;
    margin-top: 20px;
    margin-bottom: 20px;
}

table {
    width: 80%;
    margin: 20px auto;
    border-collapse: collapse;
    background-color: #fff;
    box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
}

th,
td {
    padding: 10px;
    text-align: left;
    border: 1px solid #ccc;
}

th {
    background-color: #007bff;
    color: white;
}

tr:nth-child(even) {
    background-color: #f9f9f9;
}

.center {
    text-align: center;
}

.t-btn {
    /* styling */
    border-radius: 5px;
    color: #007bff;
    text-decoration: none;
}

.t-btn:hover {
    transform: translateY(-5px);
    box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
}

.form-btn {
    display: block;
    text-align: center;
    margin-bottom: 100px;
}

.label-txt {
    font-weight: 900;
}

.form-fields {
    margin-top: 50px;
    margin-bottom: 50px;
    text-align: center;
}

.input-box {
    width: 25%;
}

.submit-btn {
    font-weight: 900;
    background-color: #007bff;
    color: white;
    border-style: solid;
    border-color: whitesmoke;
    border-radius: 5px;

    height: 5%;
    width: 10%;
}

.back-btn {
    /* styling */
    border-radius: 50%;
    background-color: #007bff;
    color: white;
    text-decoration: none;

    /* positioning */
    /* padding-top: 20px; */
    align-items: center;
    justify-content: center;
    height: 50px;
    width: 50px;
    display: flex;
    margin: auto;
    text-align: center;
}

.back-btn:hover {
    transform: translateY(-5px);
    box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
}
EOF

service apache2 restart

echo "Setup of backendserver VM has completed.">/var/log/user.log
