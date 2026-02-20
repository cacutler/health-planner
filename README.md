# health-planner

This is a calorie/fitness tracking and workout planning project built with FastAPI/Python, PostgreSQL, and Flutter/Dart.

## Features

### Planned Features

- Calorie intake tracking (possibility for a food database API connection)
- Calorie Goal Logic
- Dashboard

### Possible Features

- Apple/Google Health integration
- Premium mobile features like progress rings

## Specifications

**Flutter Frontend**

- Riverpod for state management
- Dio for HTTP client
- Freezed for immutable models
- Go Router for navigation
- SQLflite or Drift for local persistance

**Backend and Database**

- FastAPI for backend server
- PostgreSQL for database

## Database Models

**User:**

- ID
- Height in inches
- Weight in pounds
- Birthdate for age calculation
- Sex
- Activity Level

**Workout:**

- ID
- User ID
- Duration Minutes
- Intensity
- Date

**Exercise:**

- ID
- Workout ID
- Name
- Sets
- Reps
- Weight

**Nutrition Log:**

- ID
- User ID
- Food Name
- Calories
- Protein
- Carbs
- Fat
- Date

**Weight Log:**

- ID
- User ID
- Weight
- Date