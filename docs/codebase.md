```
clarity/ (project root)
│
├── backend/ (fastapi)
│   ├── app/
│   │   ├── chatbot.py (module 3 backend logic + firebase call)
│   │   ├── database.py (sqlite + sqlalchemy schema)
│   │   ├── paragraph.py (module 2 backend logic + firebase call)
│   │   └── tasker.py (module 1 backend logic + firebase call)
│   ├── app.db (sqlite database file)
│   ├── main.py (fastapi app entry, routers, cors, startup)
│   └── venv/ (python virtual environment)
│
├── extra/ (firebase – AI engine only)
│   ├── functions/                       (Firebase Cloud Functions root)
│   │   │
│   │   ├── src/
│   │   │   │
│   │   │   ├── index.ts                 (Firebase entry point:
│   │   │   │                              - exports all callable HTTP functions
│   │   │   │                              - wires Genkit flows to endpoints)
│   │   │   │
│   │   │   ├── genkit/
│   │   │   │   ├── genkit.ts             (Genkit initialization:
│   │   │   │   │                            - model config (Gemini)
│   │   │   │   │                            - API key loading
│   │   │   │   │                            - shared Genkit instance)
│   │   │   │   │
│   │   │   │   └── models.ts             (Model definitions:
│   │   │   │                                - Gemini model selection
│   │   │   │                                - temperature, safety settings)
│   │   │   │
│   │   │   ├── flows/                   (One file = one AI responsibility)
│   │   │   │   ├── tasker.flow.ts        (tasker_ai():
│   │   │   │   │                            - input schema (task text)
│   │   │   │   │                            - prompt template
│   │   │   │   │                            - output schema (steps)
│   │   │   │   │                            - NO networking logic)
│   │   │   │   │
│   │   │   │   ├── paragraph.flow.ts     (paragraph_ai():
│   │   │   │   │                            - sensory-safe rewriting prompt
│   │   │   │   │                            - tone control
│   │   │   │   │                            - readability constraints)
│   │   │   │   │
│   │   │   │   └── chatbot.flow.ts       (chatbot_ai():
│   │   │   │                                - Socratic-style prompting
│   │   │   │                                - session-aware inputs
│   │   │   │                                - conversational memory input)
│   │   │   │
│   │   │   ├── http/                    (HTTP layer exposed to FastAPI)
│   │   │   │   ├── tasker.ts             (HTTP handler:
│   │   │   │   │                            - validates request body
│   │   │   │   │                            - calls tasker.flow
│   │   │   │   │                            - returns JSON response)
│   │   │   │   │
│   │   │   │   ├── paragraph.ts          (HTTP handler for paragraph_ai)
│   │   │   │   │
│   │   │   │   └── chatbot.ts            (HTTP handler for chatbot_ai)
│   │   │   │
│   │   │   ├── schemas/                 (Zod / input-output schemas)
│   │   │   │   ├── tasker.schema.ts      (task input + steps output schema)
│   │   │   │   ├── paragraph.schema.ts   (paragraph input/output schema)
│   │   │   │   └── chatbot.schema.ts     (chat message schema)
│   │   │   │
│   │   │   ├── utils/                   (Pure helpers, no AI logic)
│   │   │   │   ├── prompt_helpers.ts     (prompt builders, formatting helpers)
│   │   │   │   └── safety_helpers.ts     (content filtering, fallback responses)
│   │   │   │
│   │   │   └── config/
│   │   │       ├── env.ts                (Environment variables loader)
│   │   │       └── constants.ts          (shared constants, limits, defaults)
│   │   │
│   │   ├── package.json                 (Node dependencies: genkit, firebase)
│   │   ├── tsconfig.json                (TypeScript config)
│   │   └── .eslintrc.js                  (Lint rules)
│   │
│   ├── firebase.json                    (Firebase project config)
│   ├── .firebaserc                      (Firebase project IDs)
│   │
│   └── README.md                        (How to deploy & test AI functions)
│
├── frontend/ (flutter)
│   ├── lib/
│   │   ├── main.dart (flutter entry point, runApp)
│   │   ├── app.dart (MaterialApp, routing, theme switching)
│   │   │
│   │   ├── config/
│   │   │   ├── themes.dart (ThemeData definitions)
│   │   │   ├── colors.dart (central color palette)
│   │   │   └── constants.dart (api url, durations, paddings)
│   │   │
│   │   ├── services/
│   │   │   ├── api_service.dart (http calls to fastapi)
│   │   │   └── session_service.dart (uuid generation + storage)
│   │   │
│   │   ├── models/
│   │   │   ├── task_model.dart (task + steps data structure)
│   │   │   ├── paragraph_model.dart (simplified text structure)
│   │   │   └── chat_model.dart (chat message structure)
│   │   │
│   │   ├── animations/
│   │   │   ├── page_transitions.dart
│   │   │   │   (custom page route animations:
│   │   │   │    - fade in
│   │   │   │    - slide up
│   │   │   │    - gentle scale
│   │   │   │    used by ALL screens)
│   │   │   │
│   │   │   ├── shared_animations.dart
│   │   │   │   (reusable animation widgets:
│   │   │   │    - FadeIn
│   │   │   │    - SlideIn
│   │   │   │    - DelayedAppear
│   │   │   │    calm, slow, non-distracting)
│   │   │   │
│   │   │   └── animation_config.dart
│   │   │       (animation constants:
│   │   │        - duration values
│   │   │        - curves
│   │   │        - delays
│   │   │        ensures consistency everywhere)
│   │   │
│   │   ├── screens/
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart
│   │   │   │   (uses shared animations for buttons + page entry)
│   │   │   │
│   │   │   ├── tasker/
│   │   │   │   ├── tasker_screen.dart
│   │   │   │   │   (animated input + submit)
│   │   │   │   └── tasker_result_screen.dart
│   │   │   │       (animated step reveal)
│   │   │   │
│   │   │   ├── paragraph/
│   │   │   │   ├── paragraph_screen.dart
│   │   │   │   └── paragraph_result_screen.dart
│   │   │   │
│   │   │   ├── chatbot/
│   │   │   │   └── chatbot_screen.dart
│   │   │   │   (message fade + gentle slide)
│   │   │   │
│   │   │   └── settings/
│   │   │       └── settings_screen.dart
│   │   │       (animated toggles + theme change)
│   │   │
│   │   ├── widgets/
│   │   │   ├── big_action_button.dart
│   │   │   │   (animated press + hover feedback)
│   │   │   ├── app_scaffold.dart
│   │   │   │   (wraps pages with common layout + animation hook)
│   │   │   └── loading_indicator.dart
│   │   │       (soft looping animation, non-stressful)
│   │   │
│   │   └── utils/
│   │       ├── validators.dart (input validation helpers)
│   │       └── helpers.dart (small reusable functions)
│   │
│   ├── assets/
│   │   ├── icons/
│   │   │   ├── tasker.svg
│   │   │   ├── paragraph.svg
│   │   │   ├── chatbot.svg
│   │   │   └── settings.svg
│   │   └── logo.svg
│   │
│   └── pubspec.yaml (dependencies, assets, fonts)
│
└── README.md (project overview + run instructions)
```
