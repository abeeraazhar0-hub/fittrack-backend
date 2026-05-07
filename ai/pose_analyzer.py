import mediapipe as mp
import numpy as np
import cv2
import base64

mp_pose = mp.solutions.pose
pose = mp_pose.Pose(min_detection_confidence=0.5, min_tracking_confidence=0.5)

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
    hip = [lm[mp_pose.PoseLandmark.LEFT_HIP.value].x,
           lm[mp_pose.PoseLandmark.LEFT_HIP.value].y]
    knee = [lm[mp_pose.PoseLandmark.LEFT_KNEE.value].x,
            lm[mp_pose.PoseLandmark.LEFT_KNEE.value].y]
    ankle = [lm[mp_pose.PoseLandmark.LEFT_ANKLE.value].x,
             lm[mp_pose.PoseLandmark.LEFT_ANKLE.value].y]
    angle = calculate_angle(hip, knee, ankle)
    if session_id not in rep_state:
        rep_state[session_id] = {"count": 0, "stage": "up", "correct": 0}
    state = rep_state[session_id]
    if angle < 90:
        state["stage"] = "down"
    if angle > 160 and state["stage"] == "down":
        state["stage"] = "up"
        state["count"] += 1
        state["correct"] += 1
    if angle < 90:
        status = "correct"
        message = "Good depth! Hold for a moment"
    elif angle < 120:
        status = "correct"
        message = "Going down, keep your back straight"
    elif angle > 160:
        status = "correct"
        message = "Standing position, start the squat"
    else:
        status = "incorrect"
        message = "Go lower, aim for 90 degrees at the knee"
    accuracy = (state["correct"] / state["count"] * 100) if state["count"] > 0 else 100.0
    return status, message, state["count"], round(accuracy, 1)

def analyze_pushup(landmarks, session_id):
    lm = landmarks
    shoulder = [lm[mp_pose.PoseLandmark.LEFT_SHOULDER.value].x,
                lm[mp_pose.PoseLandmark.LEFT_SHOULDER.value].y]
    elbow = [lm[mp_pose.PoseLandmark.LEFT_ELBOW.value].x,
             lm[mp_pose.PoseLandmark.LEFT_ELBOW.value].y]
    wrist = [lm[mp_pose.PoseLandmark.LEFT_WRIST.value].x,
             lm[mp_pose.PoseLandmark.LEFT_WRIST.value].y]
    angle = calculate_angle(shoulder, elbow, wrist)
    if session_id not in rep_state:
        rep_state[session_id] = {"count": 0, "stage": "up", "correct": 0}
    state = rep_state[session_id]
    if angle < 90:
        state["stage"] = "down"
    if angle > 160 and state["stage"] == "down":
        state["stage"] = "up"
        state["count"] += 1
        state["correct"] += 1
    if angle < 90:
        status = "correct"
        message = "Good! Push back up"
    elif angle > 160:
        status = "correct"
        message = "Top position, lower your body"
    else:
        status = "incorrect"
        message = "Keep your body straight, do not sag"
    accuracy = (state["correct"] / state["count"] * 100) if state["count"] > 0 else 100.0
    return status, message, state["count"], round(accuracy, 1)

def analyze_plank(landmarks, session_id):
    lm = landmarks
    shoulder = [lm[mp_pose.PoseLandmark.LEFT_SHOULDER.value].x,
                lm[mp_pose.PoseLandmark.LEFT_SHOULDER.value].y]
    hip = [lm[mp_pose.PoseLandmark.LEFT_HIP.value].x,
           lm[mp_pose.PoseLandmark.LEFT_HIP.value].y]
    ankle = [lm[mp_pose.PoseLandmark.LEFT_ANKLE.value].x,
             lm[mp_pose.PoseLandmark.LEFT_ANKLE.value].y]
    angle = calculate_angle(shoulder, hip, ankle)
    if 160 < angle < 200:
        status = "correct"
        message = "Perfect plank! Keep holding"
    elif angle <= 160:
        status = "incorrect"
        message = "Raise your hips, your body should be a straight line"
    else:
        status = "incorrect"
        message = "Lower your hips, do not let them sag"
    if session_id not in rep_state:
        rep_state[session_id] = {"count": 0, "stage": "holding", "correct": 0}
    return status, message, 0, 100.0

def analyze_frame(frame_base64: str, exercise_id: int, session_id: int):
    frame = decode_frame(frame_base64)
    if frame is None:
        return "incorrect", "Could not read frame", 0, 0.0
    rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = pose.process(rgb)
    if not results.pose_landmarks:
        return "incorrect", "No pose detected, make sure your full body is visible", 0, 0.0
    landmarks = results.pose_landmarks.landmark
    if exercise_id == 1:
        return analyze_squat(landmarks, session_id)
    elif exercise_id == 2:
        return analyze_pushup(landmarks, session_id)
    elif exercise_id == 3:
        return analyze_plank(landmarks, session_id)
    else:
        return analyze_squat(landmarks, session_id)
