# AFF System Project Context

## Project Overview

**Project Name**: Affiliate Marketing Data Analysis System (AFF)
**Type**: Data analysis platform for affiliate marketing campaigns
**Architecture**: DDD (Domain-Driven Design) + Frontend-Backend Separation
**Tech Stack**: Vue 3 + Spring Boot + MySQL

## Core Business Domains

The system follows DDD architecture with these core domains:

### 1. Activity Domain (`domain/activity`)
- Manages affiliate marketing campaign lifecycle
- Core entities: Activity, Offer, Campaign
- Key operations: Create, update, query activities

### 2. Tracking Domain (`domain/tracking`)
- Skro log tracking and data collection
- Traffic source tracking
- Core entities: SkroLog, TrackingEvent

### 3. Traffic Domain (`domain/traffic`)
- Traffic data analysis
- Traffic quality assessment
- Core entities: TrafficSource, TrafficMetrics

### 4. Workflow Domain (`domain/workflow`)
- Automated workflow management
- Campaign strategy execution
- Core entities: Workflow, AutomationRule

### 5. Analysis Domain (`domain/analysis`)
- Data analysis and computation
- Strategy effectiveness evaluation
- Core entities: AnalysisReport, Metrics

### 6. Shared Domain (`domain/shared`)
- Cross-domain shared models and utilities
- Value objects, common interfaces

## Technical Architecture

### Backend (Spring Boot + DDD)

```
api/src/main/java/com/aff/
├── domain/              # Domain layer - Core business logic
├── application/         # Application layer - Business orchestration
├── interfaces/          # Interface layer - REST APIs
├── adapter/            # Adapter layer - External service integration
├── infrastructure/     # Infrastructure layer - Persistence, config
└── algorithm/          # Algorithm layer - Data analysis algorithms
```

### Frontend (Vue 3 + Vite)

```
web/src/
├── views/              # Page views
├── components/         # Component library
├── composables/        # Composition functions
├── api/               # API clients
├── store/             # Pinia state management
└── router/            # Vue Router
```

## Existing Features

### 1. Activity Management
- Create and manage affiliate marketing activities
- Activity configuration: name, country, commission, vertical
- Strategy analysis and comparison

### 2. Smart Campaign
- Automated ad placement
- PropellerAds platform integration
- Campaign monitoring and optimization

### 3. Data Tracking
- Skro log tracking and synchronization
- Traffic source analysis
- Click and conversion tracking

### 4. Chart Analysis
- Visual data analysis
- Performance metrics dashboard
- Strategy comparison reports

## Database Design

### Core Tables

- **aff_activity** - Activity information
- **skro_log** - Tracking log data
- **propeller_campaign** - PropellerAds campaign data
- **system_config** - System configuration (countries, verticals, etc.)

## API Conventions

- Base path: `/api/v1/`
- RESTful design principles
- Standard HTTP methods: GET, POST, PUT, DELETE
- Response format: JSON
- Error handling: Unified exception handling
