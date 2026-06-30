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
        rep_state[session_id] = {"count": 0, "stage": "UP", "correct": 0, "min_angle": 180}
    state = rep_state[session_id]
    status = "correct"
    message = "Keep going"

    if state["stage"] == "UP" and angle < 165:
        state["stage"] = "GOING_DOWN"
        state["min_angle"] = angle
        message = "Keep going down"

    elif state["stage"] in ("GOING_DOWN", "DOWN"):
        if angle < state["min_angle"]:
            state["min_angle"] = angle
        if angle <= 110:
            state["stage"] = "DOWN"
            message = "Perfect depth! Now stand back up"
        if angle > 165:
            state["count"] += 1
            if state["min_angle"] <= 110:
                state["correct"] += 1
                message = "Rep " + str(state["count"]) + " - good form!"
            else:
                status = "incorrect"
                message = "Rep " + str(state["count"]) + " - go deeper next time!"
            state["stage"] = "UP"
            state["min_angle"] = 180

    accuracy = (state["correct"] / state["count"] * 100) if state["count"] > 0 else 100.0
    return status, message, state["count"], round(accuracy, 1)

def analyze_pushup(landmarks, session_id):
    lm = landmarks
    shoulder = [lm[mp_pose.PoseLandmark.LEFT_SHOULDER.value].x, lm[mp_pose.PoseLandmark.LEFT_SHOULDER.value].y]
    elbow = [lm[mp_pose.PoseLandmark.LEFT_ELBOW.value].x, lm[mp_pose.PoseLandmark.LEFT_ELBOW.value].y]
    wrist = [lm[mp_pose.PoseLandmark.LEFT_WRIST.value].x, lm[mp_pose.PoseLandmark.LEFT_WRIST.value].y]
    angle = calculate_angle(shoulder, elbow, wrist)
    if session_id not in rep_state:
        rep_state[session_id] = {"count": 0, "stage": "UP", "correct": 0, "min_angle": 180}
    state = rep_state[session_id]
    status = "correct"
    message = "Keep going"

    if state["stage"] == "UP" and angle < 160:
        state["stage"] = "GOING_DOWN"
        state["min_angle"] = angle
        message = "Lower your body"

    elif state["stage"] in ("GOING_DOWN", "DOWN"):
        if angle < state["min_angle"]:
            state["min_angle"] = angle
        if angle <= 90:
            state["stage"] = "DOWN"
            message = "Great! Now push back up"
        if angle > 160:
            state["count"] += 1
            if state["min_angle"] <= 90:
                state["correct"] += 1
                message = "Rep " + str(state["count"]) + " - good form!"
            else:
                status = "incorrect"
                message = "Rep " + str(state["count"]) + " - go lower next time!"
            state["stage"] = "UP"
            state["min_angle"] = 180

    accuracy = (state["correct"] / state["count"] * 100) if state["count"] > 0 else 100.0
    return status, message, state["count"], round(accuracy, 1)

def analyze_bicep_curl(landmarks, session_id):
    lm = landmarks
    shoulder = [lm[mp_pose.PoseLandmark.LEFT_SHOULDER.value].x, lm[mp_pose.PoseLandmark.LEFT_SHOULDER.value].y]
    elbow = [lm[mp_pose.PoseLandmark.LEFT_ELBOW.value].x, lm[mp_pose.PoseLandmark.LEFT_ELBOW.value].y]
    wrist = [lm[mp_pose.PoseLandmark.LEFT_WRIST.value].x, lm[mp_pose.PoseLandmark.LEFT_WRIST.value].y]
    angle = calculate_angle(shoulder, elbow, wrist)
    if session_id not in rep_state:
        rep_state[session_id] = {"count": 0, "stage": "DOWN", "correct": 0, "min_angle": 180}
    state = rep_state[session_id]
    status = "correct"
    message = "Curl your arm up"

    if state["stage"] == "DOWN" and angle < 140:
        state["stage"] = "GOING_UP"
        state["min_angle"] = angle
        message = "Keep curling up"

    elif state["stage"] in ("GOING_UP", "UP"):
        if angle < state["min_angle"]:
            state["min_angle"] = angle
        if angle <= 50:
            state["stage"] = "UP"
            message = "Great! Now lower your arm"
        if angle > 140:
            state["count"] += 1
            if state["min_angle"] <= 50:
                state["correct"] += 1
                message = "Rep " + str(state["count"]) + " - good form!"
            else:
                status = "incorrect"
                message = "Rep " + str(state["count"]) + " - curl higher next time!"
            state["stage"] = "DOWN"
            state["min_angle"] = 180

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
