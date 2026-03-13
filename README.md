# Health Planner

This is a calorie/fitness tracking and workout planning project built with FastAPI/Python, PostgreSQL, and Flutter/Dart.

## Features

### Planned Features

- Calorie intake tracking (possibility for a food database API connection)
- Calorie Goal Logic
- Dashboard

### Possible Features

- Apple/Google Health integration
- Premium mobile features like progress rings

## Database Models

**User:**

- ID
- Email
- Password
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