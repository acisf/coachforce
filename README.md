# Coachforce – AI-Powered Call Coaching on Salesforce

## 🚀 Overview

**Coachforce** is an AI-powered, autonomous coaching system built natively on Salesforce that transforms call transcripts into real-time evaluations, detects performance trends, and delivers personalized coaching at scale.

Instead of relying on manual QA reviews and delayed feedback loops, Coachforce acts as a **virtual call center supervisor**—continuously evaluating performance and guiding agents with intelligent, timely coaching.

---

## 🧠 The Problem

Call centers struggle to scale effective coaching:

- Manual evaluations are time-consuming and inconsistent  
- Coaching is reactive, often triggered only by issues  
- Identifying performance trends across agents is difficult  
- New hires lack consistent, real-time feedback  

Supervisors spend more time reviewing calls than actually developing agents.

---

## 💡 The Solution

Coachforce creates a fully automated, closed-loop system:

**Transcript → Evaluation → Trend Detection → Coaching**

Powered by **Salesforce + Generative AI + Flow + Apex**, the system continuously evaluates performance and delivers targeted coaching without requiring manual intervention.

---

## ⚙️ How It Works

### 1. Call Transcript Ingestion

Call transcripts are captured and stored in Salesforce.

- Object: `CF_Call_Transcript__c`  
- Related to: `CF_Voice_Call__c`

---

### 2. AI Evaluation (Prompt Builder)

A Prompt Builder template analyzes each transcript and returns structured JSON.

**Template:** `CF_Transcript_Evaluation`

Outputs include:

- Overall score  
- AI-generated summary  
- Primary coaching topic  
- Detailed evaluation results per criterion  

---

### 3. Structured Evaluation (Apex)

Custom Apex parses the AI response and creates structured records.

**Class:** `CF_CreateEvaluationResultsAction`

Creates:

- `CF_Call_Evaluation__c`  
- `CF_Evaluation_Result__c` (per criterion)

---

### 4. Trend Detection (Apex + Flow)

The system analyzes recent evaluations to identify meaningful performance gaps.

**Class:** `CF_AgentTrendAnalysisAction`

Detects:

- Repeated failures in specific criteria  
- Underperforming categories  
- Trends across multiple calls  

Results are stored in:

- `CF_Trend_Detection__c`

Smart logic prevents duplicate or redundant coaching within a defined timeframe.

---

### 5. AI Coaching Generation

When a trend is identified (or during onboarding), a second prompt generates a personalized coaching session.

**Template:** `CF_Coaching_Session`

Outputs:

- What the agent did well  
- Targeted improvement areas  
- Improved script example  
- Guided rehearsal scenario  

---

### 6. Coaching Delivery (Flow)

Coaching sessions are automatically created and surfaced to supervisors and agents.

- Object: `CF_Coaching_Session__c`  
- Orchestrated via Salesforce Flow  

---

## 🧠 Adaptive Coaching Modes

Coachforce intelligently adjusts coaching based on agent experience:

### 🟢 Onboarding Mode (First 2 Weeks)

- Every call is evaluated  
- Immediate coaching is generated  
- Focus on rapid skill development  

### 🔵 Cruise Control Mode

- Evaluations continue in the background  
- Coaching is triggered only when trends emerge  
- Reduces noise while maximizing impact  

---

## 🧩 Admin Configurability (Key Innovation)

Coachforce includes a **fully configurable admin interface** that allows:

- Creation of evaluation templates  
- Definition of categories and criteria  
- Custom scoring models  
- Support for any call type (sales, support, scheduling, billing, etc.)

This enables organizations to adapt Coachforce to their business **without code changes**.

---

## 🔁 End-to-End Pipeline

```
Call Transcript
      ↓
Prompt Builder (Evaluation)
      ↓
Structured JSON Output
      ↓
Apex Processing
      ↓
Evaluation Records
      ↓
Trend Detection
      ↓
Prompt Builder (Coaching)
      ↓
Coaching Session Created
```

---

## ✨ Key Features

- 🤖 AI-powered call evaluation using Prompt Builder  
- 📊 Structured, reportable evaluation data in Salesforce  
- 📈 Automated trend detection across agent performance  
- 🎯 Personalized, AI-generated coaching sessions  
- 🔁 Closed-loop learning system  
- ⚙️ Fully configurable evaluation framework  

---

## 🏗️ Architecture

### Salesforce Objects

- `CF_Call_Transcript__c`  
- `CF_Call_Evaluation__c`  
- `CF_Evaluation_Result__c`  
- `CF_Trend_Detection__c`  
- `CF_Coaching_Session__c`  

### Apex

- `CF_CreateEvaluationResultsAction`  
- `CF_AgentTrendAnalysisAction`  
- `CF_CreateCoachingSessionAction`  

### Flow

- Evaluation orchestration  
- Coaching session automation  
- Supervisor workflows  

### AI Layer (Prompt Builder)

- `CF_Transcript_Evaluation`  
- `CF_Coaching_Session`  

---

## 🎥 Demo Walkthrough

1. A call transcript is received  
2. AI evaluates the call automatically  
3. Evaluation results are stored in Salesforce  
4. Trend detection identifies coaching opportunities  
5. AI generates a personalized coaching session  
6. Supervisor reviews and delivers coaching  

---

## 📦 Deployment

```bash
sf project retrieve start --manifest manifest/package.xml
```

Assign permission sets:

- `Coachforce_Admin`  
- `Coachforce_User`  

---

## 🧠 Why This Matters

Coachforce transforms coaching from:

**Reactive → Proactive**  
**Manual → Autonomous**  
**Generic → Personalized**

It enables organizations to scale high-quality coaching across hundreds of agents—without increasing management overhead.

---

## 🔮 Future Enhancements

- Real-time coaching during live calls  
- Integration with Observe.AI and telephony platforms  
- Agent performance dashboards  
- Gamification and coaching scoring  

---

## 🏆 Built For

Salesforce Hackathon – Agentforce + Service Cloud Innovation  

---

## 👤 Author

Douglas Vann  
Senior Manager, Enterprise Applications (Salesforce)
