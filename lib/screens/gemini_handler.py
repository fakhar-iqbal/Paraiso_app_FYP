import os
import sys
import json
import base64
import google.generativeai as genai

# Ensure you set your API key
# You'll replace this with the actual API key you'll provide later
os.environ['GOOGLE_API_KEY'] = 'AIzaSyC8XDNvz149t4-Ao_PQjlnhDd_H7t2T7j0'

def process_query(restaurants_data, query, image_base64=None):
    try:
        # Initialize the model based on input type
        if image_base64:
            model = genai.GenerativeModel("gemini-1.5-pro")
            
            # Prepare input for image + text query
            prompt_parts = [
                {
                    'mime_type': 'image/jpeg', 
                    'data': image_base64
                },
                f"Query: {query}\n\nRestaurant Data: {json.dumps(restaurants_data)}"
            ]
            response = model.generate_content(prompt_parts)
        else:
            model = genai.GenerativeModel("gemini-1.5-flash")
            
            # Prepare input for text-only query
            full_prompt = f"""
            Context: You are a helpful food assistant. 
            Restaurant Data: {json.dumps(restaurants_data)}
            
            Query: {query}
            
            Instructions:
            1. Carefully analyze the restaurant data
            2. Provide a human-like, conversational response
            3. Be specific about dish availability, restaurant details
            4. If the query can't be answered from the data, say so politely
            """
            
            response = model.generate_content(full_prompt)
        
        # Return the generated text
        return json.dumps({"reply": response.text})
    
    except Exception as e:
        return json.dumps({"error": str(e)})

def main():
    try:
        # Read input from stdin
        input_data = sys.stdin.readline().strip()
        input_json = json.loads(input_data)
        
        # Extract data
        restaurants_data = input_json.get('restaurants', [])
        query = input_json.get('query', '')
        image = input_json.get('image')
        
        # Process the query
        result = process_query(restaurants_data, query, image)
        print(result)
    
    except Exception as e:
        print(json.dumps({"error": str(e)}))

if __name__ == "__main__":
    main()