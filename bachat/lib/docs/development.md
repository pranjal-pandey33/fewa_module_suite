# Project Overview

- App name : Bachat
- Flutter : 3.35.4
- Dart : 3.9.2
- Architecture : BloC with clean architecture
- Purpose : Help users track daily expenses and manage their money
- Platform : Android (Play Store)

## Architecture & Folder Structure

```
lib/
  core/
    config/
       app_config.dart
    constants/
       app_constants.dart
    utils/
      date_formatter.dart
      currency_formatter.dart
      validators.dart
    features/
      transactions/
          data/
            models/
            database/
           domain/
             entities/
            presentation/
               bloc/
               screens/
               widgets/
    main_development.dart
    main_production.dart
    
