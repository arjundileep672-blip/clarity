# Task Deconstructor
tasks
-----
| Column Name  | Type     | Constraints                | Description                    |
| ------------ | -------- | -------------------------- | ------------------------------ |
| id           | INTEGER  | PRIMARY KEY, AUTOINCREMENT | Unique task ID                 |
| session_id   | TEXT     | NOT NULL                   | Groups tasks under one session |
| input_method | TEXT     | NOT NULL                   | paragraph | audio | photo      |
| input_data   | TEXT     | NOT NULL                   | Final processed input text     |
| task_title   | TEXT     | —                          | Short AI-generated task title  |
| status       | TEXT     | NOT NULL                   | active | completed             |
| created_at   | DATETIME | NOT NULL                   | Task creation time             |
| completed_at | DATETIME | NULLABLE                   | Set when task is completed     |

task_steps
----------
| Column Name  | Type     | Constraints                | Description        |
| ------------ | -------- | -------------------------- | ------------------ |
| id           | INTEGER  | PRIMARY KEY, AUTOINCREMENT | Unique step ID     |
| task_id      | INTEGER  | NOT NULL (FK → tasks.id)   | Parent task        |
| step_index   | INTEGER  | NOT NULL                   | Execution order    |
| step_text    | TEXT     | NOT NULL                   | Instruction text   |
| is_completed | BOOLEAN  | NOT NULL                   | Checkbox state     |
| status       | TEXT     | NOT NULL                   | active | inactive  |
| created_at   | DATETIME | NOT NULL                   | Step creation time |
| completed_at | DATETIME | NULLABLE                   | Set when checked   |

# Sensory-Safe Reader
reader_sessions
---------------
| Column Name  | Type     | Constraints                | Description                 |
| ------------ | -------- | -------------------------- | --------------------------- |
| id           | INTEGER  | PRIMARY KEY, AUTOINCREMENT | Session record ID           |
| session_id   | TEXT     | NOT NULL                   | Links to frontend session   |
| input_method | TEXT     | NOT NULL                   | paragraph | audio | photo   |
| input_text   | TEXT     | NOT NULL                   | Processed input text        |
| output_text  | TEXT     | NOT NULL                   | Sensory-safe adapted output |
| created_at   | DATETIME | NOT NULL                   | Creation timestamp          |

# Socratic Buddy
chat_sessions
-------------
| Column Name | Type     | Constraints        | Description        |
| ----------- | -------- | ------------------ | ------------------ |
| id          | TEXT     | PRIMARY KEY (UUID) | Chat session ID    |
| module      | TEXT     | NOT NULL           | "chatbot"          |
| status      | TEXT     | NOT NULL           | active | ended     |
| created_at  | DATETIME | NOT NULL           | Session start time |
| ended_at    | DATETIME | NULLABLE           | Session end time   |

chat_messages
-------------
| Column Name  | Type     | Constraints                      | Description       |
| ------------ | -------- | -------------------------------- | ----------------- |
| id           | INTEGER  | PRIMARY KEY, AUTOINCREMENT       | Message ID        |
| session_id   | TEXT     | NOT NULL (FK → chat_sessions.id) | Chat session      |
| sender       | TEXT     | NOT NULL                         | user | ai         |
| message_text | TEXT     | NOT NULL                         | Message content   |
| created_at   | DATETIME | NOT NULL                         | Message timestamp |
