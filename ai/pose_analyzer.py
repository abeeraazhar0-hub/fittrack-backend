import mediapipe as mp
import numpy as np
import cv2
import base64

mp_pose = mp.solutions.pose
pose = mp_pose.Pose(min_detection_confidence=0.3, min_tracking_confidence=0.3)

rep_state = {}

def decode_frame(frame_base64: str):
    img_data = base64.b64decode(frame_base64)
    np_arr = np.frombuffer(img_data, np.uint8)
    return cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

def calculate_angle(a, b, c):
    a = np.array(a)
    b = np.array(b)
    c = np.array(c)
    radians = np.arctan2(c[1]-b[1], c[0]-b[0]) - np.arctan2(a[1]-b[1], a[0]-b[0])
    angle = np.abs(radians * 180.0 / np.pi)
    if angle > 180.0:
        angle = 360 - angle
    return angle

def analyze_squat(landmarks, session_id):
    lm = landmarks
    hip = [lm[mp_pose.PoseLandmark.LEFT_HIP.value].x, lm[mp_pose.PoseLandmark.LEFT_HIP.value].y]
    knee = [lm[mp_pose.PoseLandmark.LEFT_KNEE.value].x, lm[mp_pose.PoseLandmark.LEFT_KNEE.value].y]
    ankle = [lm[mp_pose.PoseLandmark.LEFT_ANKLE.value].x, lm[mp_pose.PoseLandmark.LEFT_ANKLE.value].y]
    angle = calculate_angle(hip, knee, ankle)
    if session_id not in rep_state:
        rep_state[session_id] = {"count": 0, "stage": "UP", "correct": 0}
    state = rep_state[session_id]
    if angle > 165:
        if state["stage"] == "DOWN":
            state["count"] += 1
            state["correct"] += 1
            message = f"Rep {state['count']} done! Keep going!"
        else:
            message = "Stand straight, now go down into squat"
        state["stage"] = "UP"
        status = "correct"
    elif angle <= 165 and angle > 110:
        status = "correct"
        message = "Keep going down, bend your knees more"
    elif angle <= 110:
        state["stage"] = "DOWN"
        status = "correct"
        message = "Perfect depth! Now stand back up"
    else:
        status = "correct"
        message = "Stand straight, now go down into squat"
    accuracy = (state["correct"] / state["count"] * 100) if state["count"] > 0 else 100.0
    return status, message, state["count"], round(accuracy, 1)

def analyze_pushup(landmarks, session_id):
    lm = landmarks
    shoulder = [lm[mp_pose.PoseLandmark.LEFT_SHOULDER.value].x, lm[mp_pose.PoseLandmark.LEFT_SHOULDER.value].y]
    elbow = [lm[mp_pose.PoseLandmark.LEFT_ELBOW.value].x, lm[mp_pose.PoseLandmark.LEFT_ELBOW.value].y]
    wrist = [lm[mp_pose.PoseLandmark.LEFT_WRIST.value].x, lm[mp_pose.PoseLandmark.LEFT_WRIST.value].y]
    angle = calculate_angle(shoulder, elbow, wrist)
    if session_id not in rep_state:
        rep_state[session_id] = {"count": 0, "stage": "UP", "correct": 0}
    state = rep_state[session_id]
    if angle > 160:
        if state["stage"] == "DOWN":
            state["count"] += 1
            state["correct"] += 1
            message = f"Rep {state['count']} done! Keep going!"
        else:
            message = "Get in pushup position, lower your body"
        state["stage"] = "UP"
        status = "correct"
    elif angle < 90:
        state["stage"] = "DOWN"
        status = "correct"
        message = "Great! Now push back up"
    else:
        status = "correct"
        message = "Keep your body straight, lower more"
    accuracy = (state["correct"] / state["count"] * 100) if state["count"] > 0 else 100.0
    return status, message, state["count"], round(accuracy, 1)

def analyze_bicep_curl(landmarks, session_id):
    lm = landmarks
    shoulder = [lm[mp_pose.PoseLandmark.LEFT_SHOULDER.value].x, lm[mp_pose.PoseLandmark.LEFT_SHOULDER.value].y]
    elbow = [lm[mp_pose.PoseLandmark.LEFT_ELBOW.value].x, lm[mp_pose.PoseLandmark.LEFT_ELBOW.value].y]
    wrist = [lm[mp_pose.PoseLandmark.LEFT_WRIST.value].x, lm[mp_pose.PoseLandmark.LEFT_WRIST.value].y]
    angle = calculate_angle(shoulder, elbow, wrist)
    if session_id not in rep_state:
        rep_state[session_id] = {"count": 0, "stage": "DOWN", "correct": 0}
    state = rep_state[session_id]
    if angle > 150:
        state["stage"] = "DOWN"
        status = "correct"
        message = "Curl your arm up!"
    elif angle < 50:
        if state["stage"] == "DOWN":
            state["count"] += 1
            state["correct"] += 1
            message = f"Rep {state['count']} done!"
        else:
            message = "Great! Now lower your arm"
        state["stage"] = "UP"
        status = "correct"
    else:
        status = "correct"
        message = "Keep curling!"
    accuracy = (state["correct"] / state["count"] * 100) if state["count"] > 0 else 100.0
    return status, message, state["count"], round(accuracy, 1)

def analyze_frame(frame_base64: str, exercise_id: int, session_id: int):
    frame = decode_frame(frame_base64)
    if frame is None:
        return "correct", "Could not read frame", 0, 100.0
    rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = pose.process(rgb)
    if not results.pose_landmarks:
        return "incorrect", "No pose detected - show your upper body", 0, 100.0
    landmarks = results.pose_landmarks.landmark
    if exercise_id == 1:
        return analyze_squat(landmarks, session_id)
    elif exercise_id == 2:
        return analyze_pushup(landmarks, session_id)
    elif exercise_id == 3:
        return analyze_bicep_curl(landmarks, session_id)
    else:
        return analyze_squat(landmarks, session_id)
