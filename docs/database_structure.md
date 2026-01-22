# Task Deconstructor
tasks
-----
id                INTEGER  PRIMARY KEY AUTOINCREMENT
session_id        TEXT     NOT NULL        -- groups the task to a session

input_method      TEXT     NOT NULL        -- paragraph | audio | photo
input_data        TEXT     NOT NULL        -- final processed text

task_title        TEXT                     -- short AI-generated title
status            TEXT     NOT NULL        -- active | completed

created_at        DATETIME NOT NULL
completed_at      DATETIME                 -- NULL until task finishes

task_steps
----------
id                INTEGER  PRIMARY KEY AUTOINCREMENT
task_id           INTEGER  NOT NULL        -- FK → tasks.id

step_index        INTEGER  NOT NULL        -- execution order
step_text         TEXT     NOT NULL        -- instruction

is_completed      BOOLEAN  NOT NULL        -- checkbox state
status            TEXT     NOT NULL        -- active | inactive

created_at        DATETIME NOT NULL
completed_at      DATETIME                 -- NULL until checked

# Sensory-Safe Reader
reader_sessions
---------------
id                INTEGER  PRIMARY KEY AUTOINCREMENT
session_id        TEXT     NOT NULL

input_method      TEXT     NOT NULL        -- paragraph | audio | photo
input_text        TEXT     NOT NULL        -- processed input text

output_text       TEXT     NOT NULL        -- mixed adapted content

created_at        DATETIME NOT NULL

# Socratic Buddy
chat_sessions
-------------
id                TEXT     PRIMARY KEY      -- UUID
module            TEXT     NOT NULL         -- "chatbot"
status            TEXT     NOT NULL         -- active | ended

created_at        DATETIME NOT NULL
ended_at          DATETIME

chat_messages
-------------
id                INTEGER  PRIMARY KEY AUTOINCREMENT
session_id        TEXT     NOT NULL          -- FK → chat_sessions.id

sender            TEXT     NOT NULL          -- user | ai
message_text      TEXT     NOT NULL

created_at        DATETIME NOT NULL
