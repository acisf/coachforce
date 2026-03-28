# Coachforce – AI-Powered Call Coaching on Salesforce

## 🚀 Overview

**Coachforce** is an AI-powered, autonomous coaching system built natively on Salesforce that transforms call transcripts into real-time evaluations, detects performance trends, and delivers personalized coaching at scale.

Instead of relying on manual QA reviews and delayed feedback loops, Coachforce acts as a **virtual call center supervisor**—continuously evaluating performance and guiding agents with intelligent, timely coaching.

---

## 🧠 The Problem

Call centers struggle to scale effective coaching:

* Manual evaluations are time-consuming and inconsistent
* Coaching is reactive, often triggered only by issues
* Identifying performance trends across agents is difficult
* New hires lack consistent, real-time feedback

Supervisors spend more time reviewing calls than actually developing agents.

---

## 💡 The Solution

Coachforce creates a fully automated, closed-loop system:

**Transcript → Evaluation → Trend Detection → Coaching**

Powered by **Salesforce + Agentforce + Generative AI + Flow + Apex**, the system continuously evaluates performance and delivers targeted coaching without requiring manual intervention.

---

## ⚙️ How It Works

### 1. Call Transcript Ingestion

* Object: `CF_Call_Transcript__c`
* Related to: `CF_Voice_Call__c`

---

### 2. AI Evaluation (Prompt Builder)

**Template:** `CF_Transcript_Evaluation`

Outputs:

* Overall score
* AI-generated summary
* Coaching topic
* Criteria-level scoring

---

### 3. Structured Evaluation (Apex)

**Class:** `CF_CreateEvaluationResultsAction`

Creates:

* `CF_Call_Evaluation__c`
* `CF_Evaluation_Result__c`

---

### 4. Trend Detection (Apex + Flow)

**Class:** `CF_AgentTrendAnalysisAction`

Detects:

* Repeated failures
* Underperforming categories
* Coaching-worthy trends

Stores results in:

* `CF_Trend_Detection__c`

---

### 5. AI Coaching Generation

**Template:** `CF_Coaching_Session`

Outputs:

* What went well
* What to improve
* Improved script
* Rehearsal scenario

---

### 6. Coaching Delivery

* Object: `CF_Coaching_Session__c`
* Delivered via Flow + Agentforce

---

## 🧠 Adaptive Coaching Modes

### 🟢 Onboarding Mode (First 14 Days)

* Evaluate every call
* Immediate coaching

### 🔵 Cruise Control Mode

* Background evaluation
* Coaching only when trends emerge

---

## 🧩 Admin Configurability

Admins can:

* Define evaluation templates
* Customize scoring criteria
* Support multiple call types

No code changes required.

---

## 🧱 Metadata Overview

Coachforce includes:

### Core Platform

* Custom Objects + Fields
* Flows + Flow Definitions
* Apex Classes + Tests
* Lightning Web Components
* FlexiPages (Record Pages + Utility Bar)
* Custom Tabs + Applications
* Permission Sets

### Agentforce / AI

* GenAI Prompt Templates
* GenAI Functions
* GenAI Planner Bundle

### UI Enhancements

* Quick Action: `Review_coaching_session`
* Call Wrap-Up Panel (LWC)

---

## 🔁 End-to-End Pipeline

```
Transcript
   ↓
AI Evaluation
   ↓
Structured Results
   ↓
Trend Detection
   ↓
AI Coaching
   ↓
Coaching Session
```

---

## 📦 Deployment

### 1. Clone Repo

```bash
git clone <your-repo-url>
cd coachforce
```

### 2. Authorize Org

```bash
sf org login web --set-default
```

### 3. Deploy Metadata

```bash
sf project deploy start --manifest manifest/package.xml
```

### 4. Assign Permission Sets

* `Coachforce_Admin`
* `Coachforce_User`

---

## ⚠️ Post-Deployment Checklist (IMPORTANT)

After deployment, verify:

* Prompt Templates are visible and active
* Flows are activated
* Agentforce planner bundle is available**
* FlexiPages are assigned to profiles/apps
* Utility Bar is visible in the app

---

## 🧪 Demo Data Setup (REQUIRED FOR DEMO)

A `demo-data/` folder is included for loading sample records.

⚠️ **Order matters — follow exactly:**

---

### Step 1: Load Contacts

File:

```
CF_demo_data_contacts_100.csv
```

Requirements:

* Add a valid `AccountId` before insert

---

### Step 2: Load Voice Calls

File:

```
CF_demo_data_voice_calls_100.csv
```

Requirements:

* `CF_Agent__c` → populate with a valid **UserId**
* `CF_Related_Record__c` → paste Contact IDs from Step 1

---

### Step 3: Load Transcripts

File:

```
CF_demo_data_cf_transcripts_100.csv
```

Requirements:

* `CF_Voice_Call__c` → paste Voice Call IDs from Step 2

---

### 💡 Pro Tip

Use Data Loader or Data Import Wizard:

* Export IDs after each step
* Copy/paste into next CSV
* Keep everything in order

---

## 🎥 Demo Flow

1. Load demo data
2. Open a Voice Call
3. View Transcript
4. Update "Call Result" field in the Voice Call
5. Evaluation auto-generates > Confirm under 'Evaluations' tab
6. Coaching session is created > Confirm under 'Coaching Sessions' tab
7. Launch Agentforce for roleplay > Confirm in 'Coachforce' Agent Builder*

*If you don't see the Coachforce agent, clone your Default Agent and name it Coachforce. Then, re-deploy the GenAI Bundle and Functions. :)

---

## 🧠 Why This Matters

Coachforce transforms coaching from:

**Reactive → Proactive**
**Manual → Autonomous**
**Generic → Personalized**

It enables scalable, consistent coaching across large teams.

---

## 🔮 Future Enhancements

* Additional Performance dashboards 
* Evaluation criteria types: add Flow/record lookup type to check if the agent entered data correctly
* Coaching session approval process
---


## 🏆 Built For

**Salesforce TDX 2026 Hackathon – Agentforce for Good**
All rights reserved.

---

## 👤 Author

Douglas Vann
Salesforce Admin
