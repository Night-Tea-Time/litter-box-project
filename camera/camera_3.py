# to avoid errors
import pathlib
temp = pathlib.PosixPath
pathlib.PosixPath = pathlib.WindowsPath
#############################################
### firebase ###

import firebase_admin
from firebase_admin import credentials, firestore, db, storage
from datetime import datetime

# firebase  function#

def uploadUsageImageToStorage(usageId, image_path):
    blob = bucket.blob(f'stool_images/{usageId}.jpg')
    blob.upload_from_filename(image_path)
    blob.make_public()
    return blob.public_url

def uploadUnrecognisedImageToStore(catId, image_path):
    blob = bucket.blob(f'cat_profile/{catId}.jpg')
    blob.upload_from_filename(image_path)
    blob.make_public()
    return blob.public_url


# function to create a new profile for unrecognised cat
def createCat(imagePath):
    # Get current date and time
    current_time = datetime.now()

    # Save cat to Firestore with an auto-generated document ID
    doc_ref = firestore_db.collection('cats').document()
    
    # Upload profile image to storage based
    url = uploadUnrecognisedImageToStore(doc_ref.id, imagePath)

    # set data to cats in Firestore
    doc_ref.set({
        'name': 'Unrecognised',
        'profileImage' : url,
        'status': True,
        'timestamp': current_time,
        'userId': userId,
    })

    print(f"Unrecognised cat added to Firestore with ID: {doc_ref.id}")

    createUnrecognisedNotification(doc_ref.id, current_time)

    return {'cat_name': 'unrecognised', 'cat_id': doc_ref.id}

# function to create a usage
def createUsage(catId, colour, shape, condition, litterboxId, imagePath):
    # return if cat is inactive
    doc_ref = firestore_db.collection('cats').document(catId)
    doc = doc_ref.get()

    if doc.exists:
        data = doc.to_dict()
        status =  data.get('status', None)

        if status == False: 
            print("Cat is inactive")
            return
    
    # Get current date and time
    current_time = datetime.now()

    # Save usage to Firestore with an auto-generated document ID
    doc_ref = firestore_db.collection('usages').document()
    
    # Upload image to storage based
    url = uploadUsageImageToStorage(doc_ref.id, imagePath)

    # set data to usage in Firestore
    doc_ref.set({
        'catId': catId,
        'colour': colour,
        'shape': shape,
        'condition': condition,
        'dateTime': current_time,
        'litterboxId': litterboxId,
        'image' : url,
        'userId': userId,
    })

    print(f"Usage added to Firestore with ID: {doc_ref.id}")

    if(condition != None):
        if( condition.lower() != "normal"):
            createAbnormalNotification(doc_ref.id, current_time)

# function to create abnormalites notification
def createAbnormalNotification(usageId, dateTime):
    # save notification to firestore
    doc_ref = firestore_db.collection('notifications').document()
    doc_ref.set({
        'usageId': usageId,
        'type': "ABNORMAL",
        'dateTime' : dateTime,
        'isViewed' : False,
        'userId': userId,
    })
    saveToRealTimeDatabase(doc_ref.id);
    print(f"Abnormal Notification added to Firestore with ID: {doc_ref.id}")

# function to create unrecognised notification
def createUnrecognisedNotification(catId, dateTime):
    # save notification to firestore
    doc_ref = firestore_db.collection('notifications').document()
    doc_ref.set({
        'catId': catId,
        'type': "UNRECOGNISED",
        'dateTime' : dateTime,
        'isViewed' : False,
        'userId': userId,
    })
    saveToRealTimeDatabase(doc_ref.id);
    print(f"Unrecognised Notification added to Firestore with ID: {doc_ref.id}")

def saveToRealTimeDatabase(usageId):
    #save notification id to realtime database
    ref = realtime_db.child(f'notification/{userId}') #users/user_id
    ref.set({
        'notificationId': usageId,
    })
    print(f"Notification ID: {usageId} added to Realtime Database!")

# only active cats profile will be recorded
def get_active_cats():
    cats_ref = firestore_db.collection('cats') 

    # Query to filter documents
    query = cats_ref.where('status', '==', True)  
    docs = query.stream() # Execute the query

    active_cats = []

    # Loop through documents and collect cat ID and name
    for doc in docs:
        doc_dict = doc.to_dict()
        cat_id = doc.id
        cat_name = doc_dict.get('name')  # Replace 'name' with the field name for cat's name
        active_cats.append({'cat_id': cat_id, 'cat_name': cat_name})

    return active_cats


## end of firebase ##
################################################

############## Classify Function ##############

def assess_poop_condition(shape, color):
    condition = ''

    if shape in ['firm', 'loose']:
        if color == 'brown':
            condition = 'normal'
        elif color =='red':
            condition = 'blood in stool'
        else:
            condition = 'abnormal color stool'

    elif shape == 'watery':
        condition = 'diarrhea'
        if color =='red':
            condition += ' and blood in stool'
        elif color != 'brown':
            condition += ' and abnormal color stool'
    elif shape == 'hard':
        condition = 'constipation'
        if color =='red':
            condition += ' and blood in stool'
        elif color != 'brown':
            condition += ' and abnormal color stool'
    else:
        condition = 'unable to recognise'
    
    return condition

# End of classify function #
##############################################

############### model function ################
    
def preprocess_image(img_path, target_size):
    img = image.load_img(img_path, target_size=target_size)
    img_array = image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)  # Create a batch dimension
    img_array /= 255.0  # Normalize the image
    return img_array


def classify_shape(img_array):
    class_names = ['firm', 'hard', 'loose','watery'] 
    predictions = shape_model.predict(img_array)
    predicted_index = np.argmax(predictions[0])
    predicted_class = class_names[predicted_index]

    return predicted_class

def classify_color(img_array):
    class_names = ['black', 'brown', 'green','red', 'yellow'] 
    predictions = color_model.predict(img_array)
    predicted_index = np.argmax(predictions[0])
    predicted_class = class_names[predicted_index]

    return predicted_class

# this function identify cat through image that pass into the model
# the model return cat name
def identify_cat(img_array, active_cats):
    class_names = ['bambi', 'duo', 'kola','lucky','miao'] 
    predictions = cat_model.predict(img_array)
    predicted_index = np.argmax(predictions[0])
    predicted_class = class_names[predicted_index]
    print(predicted_class)
    
    for cat in active_cats:
        print(cat['cat_name'].lower() == predicted_class.lower())
        if predicted_class.lower() == cat['cat_name'].lower():
            return cat
        
    #cat is unrecognised if the for loop end
    return 'unrecognised'


# End of Model function #
######################################################

## Other function
import tkinter as tk
from tkinter import filedialog

def display_stool_image(img_path, shape, color,condition):
    # Display image with prediction
    img = image.load_img(img_path)
    plt.imshow(img)
    plt.title(f'Shape: {shape} Color: {color} Condition: {condition}')
    plt.axis('off')
    plt.show()

def display_cat_image(img_path, cat):
    # Display image with prediction
    img = image.load_img(img_path)
    plt.imshow(img)
    if(cat == "unrecognised cat"):
        plt.title("unrecognised")
    else:
        plt.title(f'Cat Name: {cat['cat_name']}, Cat ID: {cat['cat_id']}')
    plt.axis('off')
    plt.show()

def select_file():
    # Create a Tkinter root window (it will not be shown)
    root = tk.Tk()
    root.withdraw()  # Hide the root window

    # Open file dialog to select an image file
    file_path = filedialog.askopenfilename(
        title="Select an image file",
        filetypes=[("Image files", "*.jpg *.jpeg *.png *.gif")]
    )

    if file_path:
        return file_path
    else:
        print("No file selected.")
        return None

        
    
    

################### Load Model ############################
import os
import numpy as np
import matplotlib.pyplot as plt
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image

file_path = 'C:/Users/weizh/Desktop/weizhen/Jun 2024 Sem 8/FYP4203 Project 1/Development/camera_iot/'

# Path to your service account key JSON file
cred = credentials.Certificate(f'{file_path}litterbox-monitoring-firebase-adminsdk-7tens-1f9e53b84e.json')


# Initialize the Firebase app with the credentials
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://litterbox-monitoring-default-rtdb.asia-southeast1.firebasedatabase.app',
    'storageBucket': 'litterbox-monitoring.appspot.com'
})

firestore_db = firestore.client() # Initialize Firestore
realtime_db = db.reference() # Initialize Realtime Database
bucket = storage.bucket() # Initialize Firebase Storage

# Load shape classifying model
shape_model = load_model(file_path + 'shape_model_finetune3_layer15.h5')

# Load color classifying model
color_model = load_model(file_path + 'color_model_finetune5_layer25.h5')

# Load cat identification model
cat_model = load_model(file_path + 'cat_model_finetune2_layer15.h5')

#### MAIN ####

print(datetime.now())
# set user
userId = "yhAQEWfu0ZQkkBX3nFfDtoxCZ1j2"

# get all cat id and their name from firestore
active_cats = get_active_cats()
print(active_cats)

#Load Image
target_size = (224, 224)

# Select cat image
cat_img_path = select_file()
# process and identify cat 
img_array = preprocess_image(cat_img_path, target_size)
cat = identify_cat(img_array, active_cats)
if(cat == "unrecognised"):
    print("unrecognised")
    cat = createCat(cat_img_path) # create cat profile
    active_cats = get_active_cats() # update the active cats list 

print(f"Cat Name: {cat['cat_name']}, Cat ID: {cat['cat_id']}")
display_cat_image(cat_img_path, cat)


#Select stool image
stool_img_path = select_file()
img_array = preprocess_image(stool_img_path, target_size)
# process and classify stool
color = classify_color(img_array)
shape = classify_shape(img_array)
condition = assess_poop_condition(shape, color)
print(f"Stool Color: {color}, Shape: {shape}, Condition: {condition}")
display_stool_image(stool_img_path,shape, color, condition)
# create usage
createUsage(cat['cat_id'], color, shape, condition, '1', stool_img_path)



