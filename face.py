import requests
import json

subscription_key = '3e41db787a1b420a9350087fed1859eb'

face_api_url = 'https://westcentralus.api.cognitive.microsoft.com/face/v1.0/detect'

headers = {'Content-Type': 'application/octet-stream', 
           'Ocp-Apim-Subscription-Key': subscription_key}

img1 = 'richard1.jpg'
img2 = 'richard2.jpg'
img3 = 'patrick.jpg'

data1 = open(img1, 'rb')
data2 = open(img2, 'rb')
data3 = open(img3, 'rb')

# Gets the binary file data1 so we can send it to MCS
# requests.post(face_api_url, headers=headers, data1=data1)
    
params = {
    'returnFaceId': 'true',
    'returnFaceLandmarks': 'false',
    'returnFaceAttributes': 'age,gender,headPose,smile,facialHair,glasses,emotion,hair,makeup,occlusion,accessories,blur,exposure,noise',
}

response1 = requests.post(face_api_url, params=params, headers=headers, data=data1)
response2 = requests.post(face_api_url, params=params, headers=headers, data=data2)
response3 = requests.post(face_api_url, params=params, headers=headers, data=data3)

print(json.dumps(response1.json()))
print(json.dumps(response2.json()))
print(json.dumps(response3.json()))

faceId1 = response1.json()[0]['faceId']
faceId2 = response2.json()[0]['faceId']
faceId3 = response3.json()[0]['faceId']

print ("faceId =", faceId1)
print ("faceId =", faceId2)
print ("faceId =", faceId3)


f1 = '99d7d516-1594-4257-9f80-2146a9d07692'
f2 = '08780db9-33df-432d-a50a-4e2634527188'
# faceId = 708ccd18-d59c-4500-9611-bd359eaddd8f

verify_api_url = 'https://westcentralus.api.cognitive.microsoft.com/face/v1.0/verify'
headers = {
    'Content-Type': 'application/json',
    'Ocp-Apim-Subscription-Key': subscription_key
    }
data = json.dumps({
    "faceId1": f1,
    "faceId2": f2
})

res = requests.post(verify_api_url, params=None, headers=headers, data=data)
print(json.dumps(res.json()))
