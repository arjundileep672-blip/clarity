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
