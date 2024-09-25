-- create a table to store bookmarks
CREATE TABLE bookmarks (
    bookmark_id INT AUTO_INCREMENT PRIMARY KEY,
    url VARCHAR(255) NOT NULL,
    title VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- create a table to store tags
CREATE TABLE tags (
    tag_id INT AUTO_INCREMENT PRIMARY KEY,
    tag_name VARCHAR(50) UNIQUE NOT NULL
);

-- create a table to associate bookmarks with tags (many-to-many relationship)
CREATE TABLE bookmark_tags (
    bookmark_id INT,
    tag_id INT,
    PRIMARY KEY (bookmark_id, tag_id),
    FOREIGN KEY (bookmark_id) REFERENCES bookmarks(bookmark_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
);

-- insert some sample bookmarks
INSERT INTO bookmarks (url, title, description)
VALUES
    ('https://www.example.com', 'Example Website', 'An example website for testing purposes.'),
    ('https://www.github.com', 'GitHub', 'A platform for hosting and collaborating on code.'),
    ('https://www.stackoverflow.com', 'Stack Overflow', 'A question and answer site for professional and enthusiast programmers.'),
    ('https://www.medium.com', 'Medium', 'An online publishing platform for articles and stories.'),
    ('https://www.docker.com', 'Docker', 'A platform for developing, shipping, and running applications using containers.'),
    ('https://www.linkedin.com', 'LinkedIn', 'A professional networking site.'),
    ('https://www.codecademy.com', 'Codecademy', 'An online platform offering coding classes and tutorials.'),
    ('https://www.kaggle.com', 'Kaggle', 'A platform for data science and machine learning competitions.'),
    ('https://www.heroku.com', 'Heroku', 'A cloud platform that enables companies to build, run, and operate applications entirely in the cloud.');


-- insert some sample tags
INSERT INTO tags (tag_name)
VALUES
    ('testing'),
    ('development'),
    ('code'),
    ('programming'),
    ('learning'),
    ('networking'),
    ('cloud'),
    ('data science'),
    ('containers'),
    ('career');

-- associate bookmarks with tags
INSERT INTO bookmark_tags (bookmark_id, tag_id)
VALUES
    (1, 1), -- Example Website -> testing
    (2, 2), -- GitHub -> development
    (2, 3), -- GitHub -> code
    (3, 1), -- Stack Overflow -> testing
    (3, 2), -- Stack Overflow -> development
    (3, 3), -- Stack Overflow -> code
    (4, 2), -- Medium -> development
    (4, 5), -- Medium -> learning
    (5, 9), -- Docker -> containers
    (5, 2), -- Docker -> development
    (6, 6), -- LinkedIn -> networking
    (6, 10), -- LinkedIn -> career
    (7, 5), -- Codecademy -> learning
    (7, 3), -- Codecademy -> code
    (8, 8), -- Kaggle -> data science
    (8, 2), -- Kaggle -> development
    (9, 7), -- Heroku -> cloud
    (9, 2); -- Heroku -> development
