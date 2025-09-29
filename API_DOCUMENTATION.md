# Top Grade API Documentation

This document provides comprehensive documentation for the TopGrade API endpoints.

### 9. Purchase Course
**POST** `/purchase`

Purchase a course with dummy payment gateway.

**Authentication Required:** Yes

**Request Body:**
```json
{
  "program_type": "program",
  "program_id": 1,
  "payment_method": "card"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Course purchased successfully!",
  "pricing": {
    "original_price": 599.00,
    "discount_percentage": 20.00,
    "discounted_price": 479.20,
    "savings": 119.80
  },
  "purchase": {
    "id": 1,
    "program_type": "program",
    "program_title": "Full Stack Web Development Bootcamp",
    "purchase_date": "2024-01-15T10:30:00Z",
    "status": "completed",
    "transaction_id": "TXN123456789"
  }
}
```

---

### 10. Get My Learnings
**GET** `/my-learnings`

Get user's purchased courses with optional status filter.

**Authentication Required:** Yes

**Query Parameters:**
- `status` (string, optional): Filter by status ('onprogress', 'completed')

**Example Request:**
```
GET /api/my-learnings?status=onprogress
```

**Response:**
```json
{
  "success": true,
  "statistics": {
    "total_courses": 1,
    "completed_courses": 0,
    "in_progress_courses": 1,
    "completion_rate": 0,
    "overall_topic_completion": 0,
    "total_topics_completed": 0,
    "total_topics_available": 4
  },
  "filter_applied": "all",
  "learnings": [
    {
      "purchase_id": 3,
      "program": {
        "id": 1,
        "title": "The master of ",
        "subtitle": "Android Developement",
        "description": "",
        "category": {
          "id": 2,
          "name": "Tech & Data"
        },
        "image": "/media/program_images/ab282f18-4577-4e9d-9605-31d0bd6b6f37.jpg",
        "duration": "6 months",
        "program_rating": 4.5,
        "is_best_seller": true,
        "is_bookmarked": false,
        "enrolled_students": 3,
        "pricing": {
          "original_price": 9999,
          "discount_percentage": 0,
          "discounted_price": 9999,
          "savings": 0
        }
      },
      "purchase_date": "2025-09-29T17:35:55.633633+00:00",
      "amount_paid": 9999,
      "progress": {
        "percentage": 0,
        "status": "onprogress",
        "completed_topics": 0,
        "total_topics": 4,
        "completed_modules": 0,
        "total_modules": 2,
        "last_activity_at": "2025-09-29T17:35:55.642650+00:00"
      }
    }
  ]
}
```

---

### 11. Update Learning Progress
**POST** `/learning/update-progress`

Update user's progress for a specific topic/video. Video duration is automatically retrieved from database.

**Authentication Required:** Yes

**Request Body:**
```json
{
  "program_type": "program",
  "topic_id": 1,
  "purchase_id": 5,
  "watch_time_seconds": 1200
}
```

**Response:**
```json
{
  "success": true,
  "message": "Progress updated successfully!",
  "topic_progress": {
    "topic_title": "HTML5 Semantic Elements",
    "status": "in_progress",
    "completion_percentage": 66.67,
    "watch_time_seconds": 1200,
    "total_duration_seconds": 1800,
    "is_completed": false,
    "last_watched_at": "2024-01-15T10:30:00Z"
  },
  "course_progress": {
    "completion_percentage": 25.5,
    "completed_topics": 3,
    "total_topics": 15,
    "is_completed": false
  }
}
```

**Notes:**
- `total_duration_seconds` is automatically retrieved from video duration stored in database
- `program_type` should match the purchase program type ('program' or 'advanced_program')
- `purchase_id` ensures security and correct program context
- Progress is considered completed at 90% watch time

---

## Data Models

### Program Object
```json
{
  "id": 1,
  "type": "program",
  "title": "Full Stack Web Development Bootcamp",
  "subtitle": "Master MERN Stack Development",
  "description": "Complete full-stack web development course...",
  "category": {
    "id": 1,
    "name": "Web Development"
  },
  "image": "/media/program_images/image.jpg",
  "duration": "16 weeks",
  "program_rating": 4.8,
  "is_best_seller": true,
  "enrolled_students": 1250,
  "pricing": {
    "original_price": 599.00,
    "discount_percentage": 20.00,
    "discounted_price": 479.20,
    "savings": 119.80
  }
}
```

### Advanced Program Object
```json
{
  "id": 1,
  "type": "advanced_program",
  "title": "AI & Machine Learning Expert Track",
  "subtitle": "Advanced Deep Learning & Neural Networks",
  "description": "Advanced course covering deep learning...",
  "category": null,
  "image": "/media/advance_program_images/image.jpg",
  "duration": "24 weeks",
  "program_rating": 4.9,
  "is_best_seller": true,
  "enrolled_students": 450,
  "pricing": {
    "original_price": 1299.00,
    "discount_percentage": 30.00,
    "discounted_price": 909.30,
    "savings": 389.70
  }
}
```

### Topic Progress Object
```json
{
  "status": "in_progress",
  "completion_percentage": 75.5,
  "watch_time_seconds": 1350,
  "total_duration_seconds": 1800,
  "last_watched_at": "2024-01-20T14:45:00Z"
}
```

---

## Error Responses

All endpoints return error responses in the following format:

```json
{
  "success": false,
  "message": "Error description"
}
```

Common HTTP status codes:
- `400` - Bad Request (Invalid parameters, validation errors)
- `401` - Unauthorized (Missing or invalid authentication)
- `404` - Not Found (Resource not found)
- `500` - Internal Server Error

---

## Authentication Notes

- **All API endpoints now require JWT authentication**
- Tokens must be included in the Authorization header as: `Bearer <token>`
- Invalid or expired tokens will result in 401 Unauthorized responses
- Authentication provides personalized responses including bookmarks and progress tracking

---

## Important Features

### Landing Page Data Structure
The landing endpoint returns 6 different sections:
1. **`top_course`** - Highest rated programs (rating ≥ 4.0), max 5 items
2. **`recently_added`** - Latest programs by ID, max 5 items
3. **`featured`** - Best seller programs, max 5 items
4. **`programs`** - Regular programs only, max 5 items
5. **`advanced_programs`** - Advanced programs only, max 5 items
6. **`continue_watching`** - Recently watched programs for authenticated users, max 2 items

### Video Access Rules
- **Intro Videos**: Always accessible regardless of purchase status (`is_intro: true`)
- **Regular Videos**: Only accessible after course purchase
- **Video URLs**: Empty string when not accessible, full URL when accessible
- **Video Duration**: Automatically calculated and stored during upload

### Bookmark System
- **Universal Bookmarking**: All endpoints include `is_bookmarked` status
- **Real-time Status**: Bookmark status reflects current user's bookmarks
- **Consistent Experience**: Same bookmark interface across all program lists

### Payment Gateway
- Uses dummy payment gateway with 90% success rate
- All successful purchases have `status: "completed"`
- Transaction IDs are auto-generated

### Progress Tracking
- **Smart Duration**: Video duration automatically retrieved from database
- **90% Completion Rule**: Videos considered completed at 90% watch time
- **Real-time Updates**: Progress updates immediately
- **Course Progress**: Based on actual module/topic counts from syllabus
- **Secure Updates**: Requires purchase_id and program_type validation

### Video Management
- **Organized Storage**: Videos stored by program subtitle in `/media/program/Program_Name/`
- **Duration Calculation**: Automatic duration extraction during upload using OpenCV/MoviePy
- **Format Support**: Supports MM:SS and HH:MM:SS duration formats

---

This API provides a complete learning platform with course browsing, purchasing, progress tracking, and personalized recommendations.