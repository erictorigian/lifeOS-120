# LifeOS-120 iOS App

A beautiful SwiftUI app for tracking health metrics and living to 120 years old.

## Features

- Secure authentication with Supabase (email/password)
- Daily tracking for:
  - Water intake (ml)
  - Exercise minutes
  - Mood score (1-10)
  - Gratitude journal
- MVVM architecture
- Keychain-based credential storage
- Apple-inspired UI design

## Project Structure

```
ios/
├── LifeOS120/
│   ├── Config/
│   │   └── SupabaseConfig.swift       # Supabase client configuration
│   ├── Models/
│   │   ├── DailyEntry.swift           # Daily health entry model
│   │   ├── Profile.swift              # User profile model
│   │   ├── LabData.swift              # Lab data model
│   │   └── Habit.swift                # Habit tracking model
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift        # Authentication logic
│   │   └── TodayViewModel.swift       # Daily entry logic
│   ├── Views/
│   │   ├── AuthView.swift             # Login/signup screen
│   │   ├── TodayView.swift            # Today's dashboard
│   │   └── MainTabView.swift          # Main navigation
│   ├── Utilities/
│   │   └── KeychainHelper.swift       # Secure credential storage
│   ├── LifeOS120App.swift             # App entry point
│   └── ContentView.swift              # Root navigation controller
└── Package.swift                      # Swift Package Manager config
```

## Setup Instructions

### Prerequisites

1. Xcode 15.0 or later
2. iOS 16.0+ target device/simulator
3. Supabase project (already configured)

### Creating the Xcode Project

Since this is currently structured as a Swift Package, you'll need to create an iOS App project:

1. Open Xcode
2. Create new project: File → New → Project
3. Choose "iOS" → "App"
4. Name: "LifeOS120"
5. Team: Your team
6. Organization Identifier: com.lifeos120 (or your identifier)
7. Interface: SwiftUI
8. Language: Swift
9. Save in: `/Users/eric/Development/lifeOS-120/ios/`

### Adding Dependencies

1. In Xcode, go to File → Add Package Dependencies
2. Add: `https://github.com/supabase/supabase-swift`
3. Version: 2.0.0 or later

### Copying Source Files

Move all files from the `LifeOS120` folder into your new Xcode project's source folder, maintaining the folder structure.

## Configuration

The app is already configured with your Supabase credentials:
- **Project URL**: https://lvzqnfleelxiwmtpwxrr.supabase.co
- **Anon Key**: Configured in `SupabaseConfig.swift`

## Testing the App

### 1. Authentication Flow

**Test Sign Up:**
1. Launch the app in simulator
2. Switch to "Sign Up" tab
3. Enter:
   - Full Name: "Test User"
   - Email: "test@example.com"
   - Password: "password123"
4. Tap "Sign Up"
5. You should see the Today dashboard

**Test Login:**
1. Sign out using the button in the toolbar
2. Switch to "Login" tab
3. Enter the same credentials
4. You should be logged back in

### 2. Daily Entry Tracking

**Test Water Tracking:**
1. On Today screen, tap "+250ml" button
2. Watch the water count increase
3. Pull to refresh - data should persist

**Test Exercise Tracking:**
1. Tap "+15min" under Exercise
2. Count should increase
3. Pull to refresh - data should persist

**Test Mood Tracking:**
1. Drag the mood slider
2. Value should update immediately
3. Pull to refresh - data should persist

**Test Gratitude Entry:**
1. Tap in gratitude text field
2. Enter: "I'm grateful for this beautiful app"
3. Tap "Save Gratitude"
4. Pull to refresh - text should persist

### 3. Data Persistence

**Verify Database Storage:**
1. After entering some data, force quit the app
2. Relaunch the app
3. Login with same credentials
4. All today's data should be restored

**Verify Keychain Storage:**
1. After logging in, force quit the app
2. Relaunch the app
3. Should automatically log in (session restored)

### 4. Profile View

1. Tap the "Profile" tab at the bottom
2. Should see your email and profile info
3. Tap "Sign Out" to test logout

## Known Limitations

- Currently only tracks today's entry (historical view coming soon)
- No data visualization yet (charts/graphs planned)
- No push notifications for reminders
- No Apple Health integration yet

## Next Steps

1. **Create Xcode Project** following the setup instructions above
2. **Test Authentication** using the test cases
3. **Add Features**:
   - Historical data view
   - Charts and analytics
   - Lab data entry
   - Habit tracking
   - AI recommendations
   - Apple Health integration

## Architecture

### MVVM Pattern

- **Models**: Data structures matching Supabase schema
- **Views**: SwiftUI views with no business logic
- **ViewModels**: Observable objects managing state and API calls

### Security

- Authentication tokens stored in iOS Keychain
- Row Level Security (RLS) enabled on all tables
- No credentials stored in UserDefaults

### Data Flow

1. User interacts with View
2. View calls ViewModel method
3. ViewModel makes Supabase API call
4. ViewModel updates @Published properties
5. View automatically re-renders

## Support

For issues or questions, check:
- Supabase dashboard: https://supabase.com/dashboard
- Supabase Swift SDK docs: https://github.com/supabase/supabase-swift
- SwiftUI documentation: https://developer.apple.com/documentation/swiftui
