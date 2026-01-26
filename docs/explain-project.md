# About Project
- we are working on project for ADHD People, to help them manage things, and help them with their mental stress
- in this project we are basically solving 3 main modules
    1. Task deconstructor (tasker) # module 1
    2. Sensory Safe Reader (paragraph) # module 2
    3. Socratic Buddy (chatbot) # module 3
- so for that these are the techstacks we are using

## techstack
### fastapi -> this will be the main backend framework
- it will handle routing
- it will handle db
- it will connect to backend
- it should be able to call firebase functions to deal with AI
- it should be able to call sqliite to deal with data storing
- it should be able to call flutter to deal with the frontend part

### firebase -> this will be for AI backend, using `genkit` for AI things
- it will handle the genkit API key, and takes input from fastapi
- then process that data into genkit, then result will be sent back to fastapi
- so basically firebase is working as AI engine, which provides some predefined functions so that fastapi can call firebase for ai stuff
    1. tasker_ai() -> for handling module 1
    2. paragraph_ai() -> for handling module 2
    3. chatbot_ap() -> for handling module 3
- it should also have some directory called "prompts/" in which there will be three more directory, which holds text files for initial prompting
    1. prompts/tasker/*.txt
    2. prompts/paragraph/*.txt
    3. prompts/chatbot/*.txt
- like before the AI comes in action, the respective module ai should read the prompts inside those respective directories

### flutter -> this will be for frontend (website, android app)
- it should be clean and simple, not too fancy, just simple ui
- like also we want to add theme selecting feature in settings, so like we want atleast 3 themes, the template will be same, the only thing changes is color, and icons
- it should be simple and fast

#### default colorscheme
| Color | Hex | Purpose |
|-------|-----|---------|
| Mint Green | `#A8D5BA` | Primary actions, emphasis |
| Muted Blue | `#B8C9E8` | Secondary actions |
| Soft Lavender | `#E6D5F5` | Accent, panic button |
| Warm Cream | `#FBF7F0` | Background |
| Light Cream | `#F5F0E8` | Surface/cards |
| Soft Black | `#3D3D3D` | Primary text |
| Medium Gray | `#6B6B6B` | Secondary text |

#### index page (the startup page at "/")
- at right top corner there will be settings icon (icon will be saved in assets/logo.svg)
- at left top corner there will be logo of our project (icon will be saved in assets/icons/settings.svg)
- and there will be 3 options (big bar like buttons) in the middle of the screen in rows
    1. "Task Deconstructor" (for tasker module),
    2. "Sensory Safe Reader" (for paragraph module)
    3. "Socratic Buddy" (for paragraph module)
    > there should be icons at begining of these buttons, and saved in assets/icons, with their names (tasker.svg, paragraph.svg and chatbot.svg)

# File Structure
```
clarity/
│
├── backend/
│   ├── app/
│   │   ├── chatbot.py
│   │   ├── database.py
│   │   ├── paragraph.py
│   │   └── tasker.py
│   ├── app.db
│   ├── main.py
│   └── venv/
│
├── extra/
│   ├── functions/
│   │   ├── src/
│   │   │   ├── index.ts
│   │   │   ├── genkit/
│   │   │   │   ├── genkit.ts
│   │   │   │   └── models.ts
│   │   │   ├── flows/
│   │   │   │   ├── tasker.flow.ts
│   │   │   │   ├── paragraph.flow.ts
│   │   │   │   └── chatbot.flow.ts
│   │   │   ├── http/
│   │   │   │   ├── tasker.ts
│   │   │   │   ├── paragraph.ts
│   │   │   │   └── chatbot.ts
│   │   │   ├── schemas/
│   │   │   │   ├── tasker.schema.ts
│   │   │   │   ├── paragraph.schema.ts
│   │   │   │   └── chatbot.schema.ts
│   │   │   ├── utils/
│   │   │   │   ├── prompt_helpers.ts
│   │   │   │   └── safety_helpers.ts
│   │   │   └── config/
│   │   │       ├── env.ts
│   │   │       └── constants.ts
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── .eslintrc.js
│   ├── firebase.json
│   ├── .firebaserc
│   └── README.md
│
├── frontend/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart
│   │   ├── config/
│   │   │   ├── themes.dart
│   │   │   ├── colors.dart
│   │   │   └── constants.dart
│   │   ├── services/
│   │   │   ├── api_service.dart
│   │   │   └── session_service.dart
│   │   ├── models/
│   │   │   ├── task_model.dart
│   │   │   ├── paragraph_model.dart
│   │   │   └── chat_model.dart
│   │   ├── screens/
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart
│   │   │   ├── tasker/
│   │   │   │   ├── tasker_screen.dart
│   │   │   │   └── tasker_result_screen.dart
│   │   │   ├── paragraph/
│   │   │   │   ├── paragraph_screen.dart
│   │   │   │   └── paragraph_result_screen.dart
│   │   │   ├── chatbot/
│   │   │   │   └── chatbot_screen.dart
│   │   │   └── settings/
│   │   │       └── settings_screen.dart
│   │   ├── widgets/
│   │   │   ├── big_action_button.dart
│   │   │   ├── app_scaffold.dart
│   │   │   └── loading_indicator.dart
│   │   └── utils/
│   │       ├── validators.dart
│   │       └── helpers.dart
│   ├── assets/
│   │   ├── icons/
│   │   │   ├── tasker.svg
│   │   │   ├── paragraph.svg
│   │   │   ├── chatbot.svg
│   │   │   └── settings.svg
│   │   └── logo.svg
│   └── pubspec.yaml
│
└── README.md
```

# Flow
## Techstack flow
```
- USER -> Flutter -> FastAPI -> firebase -> FastAPI -> Flutter -> USER
                                    |--> app.db             |--> app.db
```

MODULE 1 – TASK DECONSTRUCTOR
----------------------------

```
UI FLOW (Flutter only):
home_screen.dart
  -> tasker_screen.dart
      -> (submit button)
          -> loading state (inline / overlay)
          -> tasker_result_screen.dart
  -> home_screen.dart (optional back)

DATA FLOW (runtime, invisible):
tasker_screen.dart
  -> api_service.sendTask()
      -> FastAPI /tasker endpoint
          -> tasker.py
              -> Firebase tasker_ai()
              -> returns JSON response
      -> api_service receives response
  -> loading state ends
  -> tasker_result_screen.dart displays data
```

MODULE 2 – SENSORY SAFE READER
-----------------------------

```
UI FLOW:
home_screen.dart
  -> paragraph_screen.dart
      -> (submit button)
          -> loading state (inline / overlay)
          -> paragraph_result_screen.dart
  -> home_screen.dart

DATA FLOW:
paragraph_screen.dart
  -> api_service.sendParagraph()
      -> FastAPI /paragraph endpoint
          -> paragraph.py
              -> Firebase paragraph_ai()
              -> returns simplified text
      -> api_service receives response
  -> loading state ends
  -> paragraph_result_screen.dart displays data
```

MODULE 3 – SOCRATIC BUDDY (CHATBOT)
----------------------------------

```
UI FLOW:
home_screen.dart
  -> chatbot_screen.dart
      -> (continuous chat)
          -> per-message loading indicator
  -> home_screen.dart

DATA FLOW (repeats per message):
chatbot_screen.dart
  -> api_service.sendChat(message, session_id)
      -> FastAPI /chatbot endpoint
          -> chatbot.py
              -> Firebase chatbot_ai()
              -> returns reply
      -> api_service receives response
  -> loading indicator removed
  -> chatbot_screen.dart appends bot message
```

LOADING IMPLEMENTATION SUMMARY
------------------------------

```
- Loading is a UI STATE, not a screen
- Implemented via widgets/loading_indicator.dart
- Triggered inside:
  - tasker_screen.dart
  - paragraph_screen.dart
  - chatbot_screen.dart (per message)
```
