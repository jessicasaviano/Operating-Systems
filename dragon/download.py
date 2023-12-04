import requests

def download_binary_file(url, filename):
    response = requests.get(url, stream=True)

    if response.status_code == 200:
        with open(filename, 'wb') as file:
            for chunk in response.iter_content(chunk_size=8192): 
                file.write(chunk)
    else:
        print(f"Failed to download file: status code {response.status_code}")

# Example usage
url = "https://www.cs.virginia.edu/~skadron/cs4414/laptop_image"
filename = "laptop_image.bin"
download_binary_file(url, filename)