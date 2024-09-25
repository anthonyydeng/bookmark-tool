<?php

$serverhost = '192.168.56.12';
$dbname = 'bookmark_tool';
$username = 'webuser';
$password = 'lolpassword';

// Create connection
$conn = new mysqli($serverhost, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Handle insertion of a new bookmark
if (isset($_POST['add'])) {
    $title = $conn->real_escape_string($_POST['title']);
    $url = $conn->real_escape_string($_POST['url']);
    $description = $conn->real_escape_string($_POST['description']);
    $tags = explode(',', $_POST['tags']);

    // Insert into bookmarks table
    $sql = "INSERT INTO bookmarks (title, url, description) VALUES ('$title', '$url', '$description')";
    if ($conn->query($sql) === TRUE) {
        $bookmark_id = $conn->insert_id;

        // Insert tags into tags table and link to bookmark
        foreach ($tags as $tag) {
            $tag = trim($tag);
            $tag_sql = "INSERT INTO tags (tag_name) VALUES ('$tag') ON DUPLICATE KEY UPDATE tag_id=LAST_INSERT_ID(tag_id)";
            if ($conn->query($tag_sql) === TRUE) {
                $tag_id = $conn->insert_id;
                $conn->query("INSERT INTO bookmark_tags (bookmark_id, tag_id) VALUES ('$bookmark_id', '$tag_id')");
            }
        }

        // Redirect back to index.php
        header("Location: index.php");
        exit();
    }
}

// Handle deletion of a bookmark
if (isset($_GET['delete'])) {
    $bookmark_id = intval($_GET['delete']);
    // Delete from bookmark_tags first (foreign key constraint)
    $conn->query("DELETE FROM bookmark_tags WHERE bookmark_id = $bookmark_id");
    // Then delete from bookmarks
    $conn->query("DELETE FROM bookmarks WHERE bookmark_id = $bookmark_id");

    // Redirect back to index.php
    header("Location: index.php");
    exit();
}

// Handle update of a bookmark
if (isset($_POST['update'])) {
    $bookmark_id = intval($_POST['bookmark_id']);
    $title = $conn->real_escape_string($_POST['title']);
    $url = $conn->real_escape_string($_POST['url']);
    $description = $conn->real_escape_string($_POST['description']);
    $tags = explode(',', $_POST['tags']);

    // Update the bookmarks table
    $sql = "UPDATE bookmarks SET title = '$title', url = '$url', description = '$description' WHERE bookmark_id = $bookmark_id";
    if ($conn->query($sql) === TRUE) {
        // Delete existing tags for the bookmark
        $conn->query("DELETE FROM bookmark_tags WHERE bookmark_id = $bookmark_id");

        // Insert updated tags
        foreach ($tags as $tag) {
            $tag = trim($tag);
            $tag_sql = "INSERT INTO tags (tag_name) VALUES ('$tag') ON DUPLICATE KEY UPDATE tag_id=LAST_INSERT_ID(tag_id)";
            if ($conn->query($tag_sql) === TRUE) {
                $tag_id = $conn->insert_id;
                $conn->query("INSERT INTO bookmark_tags (bookmark_id, tag_id) VALUES ('$bookmark_id', '$tag_id')");
            }
        }

        // Redirect back to index.php
        header("Location: index.php");
        exit();
    }
}

// If editing, retrieve the existing data
if (isset($_GET['edit'])) {
    $bookmark_id = intval($_GET['edit']);
    $result = $conn->query("SELECT * FROM bookmarks WHERE bookmark_id = $bookmark_id");

    if ($result->num_rows > 0) {
        $bookmark = $result->fetch_assoc();
        $title = $bookmark['title'];
        $url = $bookmark['url'];
        $description = $bookmark['description'];

        // Retrieve the associated tags
        $tags_result = $conn->query("SELECT t.tag_name FROM tags t INNER JOIN bookmark_tags bt ON t.tag_id = bt.tag_id WHERE bt.bookmark_id = $bookmark_id");
        $tags = [];
        while ($tag_row = $tags_result->fetch_assoc()) {
            $tags[] = $tag_row['tag_name'];
        }
        $tags = implode(', ', $tags);
    }
}

$conn->close();
?>

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>

<head>
    <title>Edit Bookmark</title>
    <link rel="stylesheet" href="style.css">
</head>

<body>
    <h1><?php echo isset($bookmark_id) ? 'Edit Bookmark' : 'Add New Bookmark'; ?></h1>

    <form class="form-fields" method="post" action="edit.php">
        <input type="hidden" name="bookmark_id" value="<?php echo isset($bookmark_id) ? $bookmark_id : ''; ?>">
        <p>
            <label class="label-txt">Title:</label>
            <input class="input-box" type="text" name="title" placeholder="Name" value="<?php echo isset($title) ? htmlspecialchars($title) : ''; ?>" required>
        </p>
        <p>
            <label class="label-txt">URL:</label>
            <input class="input-box" type="url" name="url" placeholder="https://www.example.com" value="<?php echo isset($url) ? htmlspecialchars($url) : ''; ?>" required>
        </p>
        <p>
            <label class="label-txt">Description:</label>
            <textarea class="input-box" name="description" placeholder="Description" required><?php echo isset($description) ? htmlspecialchars($description) : ''; ?></textarea>
        </p>
        <p>
            <label class="label-txt">Tags (comma-separated):</label>
            <input class="input-box" type="text" name="tags" placeholder="Tags" value="<?php echo isset($tags) ? htmlspecialchars($tags) : ''; ?>">
        </p>
        <p>
            <button class="submit-btn" type="submit" name="<?php echo isset($bookmark_id) ? 'update' : 'add'; ?>">
                <?php echo isset($bookmark_id) ? 'Update Bookmark' : 'Add Bookmark'; ?>
            </button>
        </p>
    </form>

    <a class="back-btn" href="index.php">←</a>

</body>

</html>