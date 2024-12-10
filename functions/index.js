// // /**
// //  * Import function triggers from their respective submodules:
// //  */
// // const { onRequest } = require("firebase-functions/v2/https");
// // const logger = require("firebase-functions/logger");
// // const admin = require("firebase-admin");
// // const axios = require("axios");

// // // Initialize Firebase Admin SDK
// // admin.initializeApp();
// // const db = admin.firestore();

// // // Retrieve Gemini API Key from environment variables
// // const GEMINI_API_KEY = "AIzaSyBdyI-UDzUS-ekazlKktQpPDLeyVQ4jJa4";
// // if (!GEMINI_API_KEY) {
// //     throw new Error("Gemini API Key is missing.");
// // }


// // // Cloud Function to handle chatbot requests
// // // exports.chatbot = onRequest(async (req, res) => {
// // //     const { message } = req.body;

// // //     if (!message) {
// // //         res.status(400).json({ reply: "Invalid input. Please provide a message." });
// // //         return;
// // //     }

// // //     try {
// // //         // Process the message with Gemini API
// // //         const intentResponse = await processMessageWithGemini(message);

// // //         // Query Firestore dynamically based on the interpreted intent
// // //         const response = await queryFirestore(intentResponse);

// // //         res.status(200).json({ reply: response });
// // //     } catch (error) {
// // //         logger.error("Error processing request:", error);
// // //         res.status(500).json({ reply: "An error occurred while processing your request." });
// // //     }
// // // });

// // exports.chatbot = onRequest(async (req, res) => {
// //     const { message } = req.body;

// //     if (!message) {
// //         res.status(400).json({ reply: "Invalid input. Please provide a message." });
// //         return;
// //     }

// //     try {
// //         console.log("Incoming message:", message); // Log the input message
// //         const intentResponse = await processMessageWithGemini(message);
// //         console.log("Gemini Intent:", intentResponse); // Log the intent

// //         const response = await queryFirestore(intentResponse);
// //         console.log("Firestore Response:", response); // Log the Firestore result

// //         res.status(200).json({ reply: response });
// //     } catch (error) {
// //         console.error("Error processing request:", error); // Log the error
// //         res.status(500).json({ reply: "An error occurred while processing your request." });
// //     }
// // });


// // // Function to process the message using Gemini API
// // async function processMessageWithGemini(message) {
// //     console.log("Gemini API request payload:", message);
// //     try {
// //         const response = await axios.post(
// //             "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent",
// //             {
// //                 contents: [{ parts: [{ text: message }] }],
// //             },
// //             {
// //                 headers: {
// //                     Authorization: `Bearer ${GEMINI_API_KEY}`,
// //                     "Content-Type": "application/json",
// //                 },
// //             }
// //         );
// //         console.log("Gemini API response:", response.data);

// //         const intent = response.data?.contents?.[0]?.parts?.[0]?.text?.trim();
// //         if (!intent) throw new Error("No intent returned from Gemini API.");
// //         logger.info("Gemini Intent:", intent);
// //         return intent;
// //     } catch (error) {
// //         logger.error("Gemini API Error:", error.response?.data || error.message);
// //         throw new Error("Failed to process the message with Gemini API.");
// //     }
// // }

// // // Function to query Firestore dynamically based on the interpreted intent
// // async function queryFirestore(intent) {
// //     console.log("Intent received:", intent);
// //     try {
// //         if (intent.includes("list restaurants")) {
// //             const snapshot = await db.collection("restaurantAdmins").get();
// //             const restaurants = snapshot.docs.map((doc) => {
// //                 const data = doc.data();
// //                 return `${data.name}: ${data.category}, Located at ${data.address}`;
// //             });
// //             return restaurants.join("\n");
// //         } else if (intent.includes("discounted items")) {
// //             const snapshot = await db.collectionGroup("items").where("discountedPrice", ">", 0).get();
// //             const discountedItems = snapshot.docs.map((doc) => {
// //                 const data = doc.data();
// //                 return `${data.name} - ${data.discountedPrice} PKR (${data.discount} off)`;
// //             });
// //             return discountedItems.join("\n");
// //         } else if (intent.includes("working hours")) {
// //             const snapshot = await db.collection("restaurantAdmins").get();
// //             const workingHours = snapshot.docs.map((doc) => {
// //                 const data = doc.data();
// //                 return `${data.name}: Open from ${data.openingHrs}`;
// //             });
// //             return workingHours.join("\n");
// //         } else if (intent.includes("menu for")) {
// //             const restaurantName = intent.replace("menu for", "").trim();
// //             const snapshot = await db.collection("restaurantAdmins").where("name", "==", restaurantName).get();

// //             if (snapshot.empty) {
// //                 return `No restaurant found with the name "${restaurantName}".`;
// //             }

// //             const restaurantDoc = snapshot.docs[0];
// //             const itemsSnapshot = await restaurantDoc.ref.collection("items").get();
// //             const menu = itemsSnapshot.docs.map((doc) => {
// //                 const itemData = doc.data();
// //                 return `${itemData.name} - ${itemData.prices.Small || "N/A"} (Small), ${itemData.prices.Medium || "N/A"} (Medium), ${itemData.prices.Large || "N/A"} (Large)`;
// //             });

// //             return menu.join("\n");
// //         } else {
// //             return "Sorry, I couldn't understand your query. Please rephrase it.";
// //         }
// //     } catch (error) {
// //         logger.error("Firestore Query Error:", error);
// //         throw new Error("Failed to fetch data from Firestore.");
// //     }
// // }


// /**
//  * Import function triggers from their respective submodules:
//  */
// const { onRequest } = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");
// const admin = require("firebase-admin");
// const axios = require("axios");
// const { GoogleAuth } = require("google-auth-library"); // Import GoogleAuth for OAuth 2.0

// // Initialize Firebase Admin SDK
// admin.initializeApp();
// const db = admin.firestore();

// // Initialize Google Auth
// const auth = new GoogleAuth({
//     scopes: ["https://www.googleapis.com/auth/generative.language"], // Required scope for Gemini API
// });

// // Cloud Function to handle chatbot requests
// exports.chatbot = onRequest(async (req, res) => {
//     const { message } = req.body;

//     if (!message) {
//         res.status(400).json({ reply: "Invalid input. Please provide a message." });
//         return;
//     }

//     try {
//         console.log("Incoming message:", message); // Log the input message

//         // Process the message with Gemini API
//         const intentResponse = await processMessageWithGemini(message);
//         console.log("Gemini Intent:", intentResponse); // Log the intent

//         // Query Firestore dynamically based on the interpreted intent
//         const response = await queryFirestore(intentResponse);
//         console.log("Firestore Response:", response); // Log the Firestore result

//         res.status(200).json({ reply: response });
//     } catch (error) {
//         logger.error("Error processing request:", error); // Log the error
//         res.status(500).json({ reply: "An error occurred while processing your request." });
//     }
// });

// // Function to process the message using Gemini API
// async function processMessageWithGemini(message) {
//     console.log("Gemini API request payload:", message);
//     try {
//         // Get OAuth 2.0 access token
//         const client = await auth.getClient();
//         const accessToken = await client.getAccessToken();

//         // Make the Gemini API call
//         const response = await axios.post(
//             "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent",
//             {
//                 contents: [{ parts: [{ text: message }] }],
//             },
//             {
//                 headers: {
//                     Authorization: `Bearer ${accessToken}`, // Use OAuth token
//                     "Content-Type": "application/json",
//                 },
//             }
//         );

//         console.log("Gemini API response:", response.data);
//         const intent = response.data?.contents?.[0]?.parts?.[0]?.text?.trim();
//         if (!intent) throw new Error("No intent returned from Gemini API.");
//         return intent;
//     } catch (error) {
//         logger.error("Gemini API Error:", error.response?.data || error.message);
//         throw new Error("Failed to process the message with Gemini API.");
//     }
// }

// // Function to query Firestore dynamically based on the interpreted intent
// async function queryFirestore(intent) {
//     console.log("Intent received:", intent);
//     try {
//         if (intent.includes("list restaurants")) {
//             const snapshot = await db.collection("restaurantAdmins").get();
//             const restaurants = snapshot.docs.map((doc) => {
//                 const data = doc.data();
//                 return `${data.name}: ${data.category}, Located at ${data.address}`;
//             });
//             return restaurants.join("\n");
//         } else if (intent.includes("discounted items")) {
//             const snapshot = await db.collectionGroup("items").where("discountedPrice", ">", 0).get();
//             const discountedItems = snapshot.docs.map((doc) => {
//                 const data = doc.data();
//                 return `${data.name} - ${data.discountedPrice} PKR (${data.discount} off)`;
//             });
//             return discountedItems.join("\n");
//         } else if (intent.includes("working hours")) {
//             const snapshot = await db.collection("restaurantAdmins").get();
//             const workingHours = snapshot.docs.map((doc) => {
//                 const data = doc.data();
//                 return `${data.name}: Open from ${data.openingHrs}`;
//             });
//             return workingHours.join("\n");
//         } else if (intent.includes("menu for")) {
//             const restaurantName = intent.replace("menu for", "").trim();
//             const snapshot = await db.collection("restaurantAdmins").where("name", "==", restaurantName).get();

//             if (snapshot.empty) {
//                 return `No restaurant found with the name "${restaurantName}".`;
//             }

//             const restaurantDoc = snapshot.docs[0];
//             const itemsSnapshot = await restaurantDoc.ref.collection("items").get();
//             const menu = itemsSnapshot.docs.map((doc) => {
//                 const itemData = doc.data();
//                 return `${itemData.name} - ${itemData.prices?.Small || "N/A"} (Small), ${itemData.prices?.Medium || "N/A"} (Medium), ${itemData.prices?.Large || "N/A"} (Large)`;
//             });

//             return menu.join("\n");
//         } else {
//             return "Sorry, I couldn't understand your query. Please rephrase it.";
//         }
//     } catch (error) {
//         logger.error("Firestore Query Error:", error);
//         throw new Error("Failed to fetch data from Firestore.");
//     }
// }



/**
 * index.js
 * Firebase Cloud Function integrating Generative AI, Vision API, and Firestore.
 */

const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const axios = require("axios");
const { GoogleAuth } = require("google-auth-library");

admin.initializeApp();
const db = admin.firestore();

// Auth clients for APIs
const languageAuth = new GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/generative.language"],
});

const visionAuth = new GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/cloud-platform"],
});

exports.chatbot = onRequest(async (req, res) => {
    try {
        const { message, image } = req.body;

        if (!message && !image) {
            return res.status(400).json({ reply: "Please provide a message or an image." });
        }

        let structuredIntent;
        if (image) {
            // Handle image input
            const label = await detectImageLabel(image);
            // Use LLM to interpret the image context. We ask the LLM:
            // "User sent an image likely showing X. Return JSON intent."
            structuredIntent = await interpretMessageWithLLM(
                `The user sent an image that likely shows: ${label}.\nWhat might the user want from the database? Return a JSON like:\n{"intent":"...", "category":"...", "restaurant_name":"..."}`
            );
        } else {
            // Handle text input
            structuredIntent = await interpretMessageWithLLM(
                `User asked: "${message}".\nReturn a JSON object describing the user's intent, for example:\n{"intent":"get_restaurant_menu", "restaurant_name":"Pizza Palace"}`
            );
        }

        console.log("Structured Intent:", structuredIntent);
        const dbResponse = await queryFirestore(structuredIntent);
        res.status(200).json({ reply: dbResponse });
    } catch (error) {
        logger.error("Error processing request:", error);
        res.status(500).json({ reply: "An error occurred while processing your request." });
    }
});

/**
 * Calls Vision API to detect labels in the provided base64 image string.
 */
async function detectImageLabel(base64Image) {
    const client = await visionAuth.getClient();
    const token = (await client.getAccessToken()).token;

    const visionResponse = await axios.post(
        "https://vision.googleapis.com/v1/images:annotate",
        {
            requests: [
                {
                    image: { content: base64Image },
                    features: [{ type: "LABEL_DETECTION", maxResults: 3 }]
                }
            ]
        },
        {
            headers: {
                Authorization: `Bearer ${token}`,
                "Content-Type": "application/json"
            }
        }
    );

    const annotations = visionResponse.data.responses[0].labelAnnotations || [];
    if (annotations.length > 0) {
        return annotations[0].description; // top label
    } else {
        return "unknown";
    }
}

/**
 * Interprets user query (text or image label context) using chat-bison model.
 * We instruct the model to return a structured JSON.
 */
async function interpretMessageWithLLM(contextText) {
    const client = await languageAuth.getClient();
    const accessToken = await client.getAccessToken();

    const response = await axios.post(
        "https://generativelanguage.googleapis.com/v1beta2/models/chat-bison-001:generateMessage",
        {
            prompt: {
                messages: [
                    {
                        author: "user",
                        content: contextText + "\n\nIMPORTANT: Return only a JSON object with fields like {\"intent\":\"...\", \"restaurant_name\":\"...\", \"category\":\"...\"} and no extra commentary."
                    }
                ]
            }
        },
        {
            headers: {
                Authorization: `Bearer ${accessToken}`,
                "Content-Type": "application/json",
            },
        }
    );

    // const intentJSON = response.data?.candidates?.[0]?.content?.trim();
    const intentJSON = response.data?.candidates?.[0]?.content?.trim();
    console.log("LLM raw intent:", intentJSON);

    try {
        return JSON.parse(intentJSON);
    } catch (err) {
        throw new Error("LLM did not return valid JSON: " + intentJSON);
    }
}

/**
 * Dynamically queries Firestore based on the LLM interpreted intent.
 */
async function queryFirestore(intentObj) {
    const { intent, restaurant_name, category } = intentObj || {};

    if (!intent) {
        return "Sorry, I couldn't understand your request.";
    }

    try {
        switch (intent) {
            case "list_restaurants":
                {
                    const snapshot = await db.collection("restaurantAdmins").get();
                    if (snapshot.empty) {
                        return "No restaurants found.";
                    }
                    const restaurants = snapshot.docs.map((doc) => {
                        const data = doc.data();
                        return `${data.name}: ${data.category}, located at ${data.address}`;
                    });
                    return restaurants.join("\n");
                }

            case "get_working_hours":
                {
                    const snapshot = await db.collection("restaurantAdmins").get();
                    if (snapshot.empty) {
                        return "No restaurants found.";
                    }
                    const workingHours = snapshot.docs.map((doc) => {
                        const data = doc.data();
                        return `${data.name}: Open from ${data.openingHrs}`;
                    });
                    return workingHours.join("\n");
                }

            case "get_discounted_items":
                {
                    const snapshot = await db.collectionGroup("items").where("discountedPrice", ">", 0).get();
                    if (snapshot.empty) {
                        return "No discounted items found.";
                    }
                    const discountedItems = snapshot.docs.map((doc) => {
                        const data = doc.data();
                        return `${data.name} - ${data.discountedPrice} PKR (${data.discount || 'some'} off)`;
                    });
                    return discountedItems.join("\n");
                }

            case "get_restaurant_menu":
                {
                    if (!restaurant_name) return "Please specify the restaurant name.";
                    const snapshot = await db.collection("restaurantAdmins").where("name", "==", restaurant_name).get();

                    if (snapshot.empty) {
                        return `No restaurant found with the name "${restaurant_name}".`;
                    }

                    const restaurantDoc = snapshot.docs[0];
                    const itemsSnapshot = await restaurantDoc.ref.collection("items").get();
                    if (itemsSnapshot.empty) {
                        return `No menu items found for "${restaurant_name}".`;
                    }

                    const menu = itemsSnapshot.docs.map((doc) => {
                        const itemData = doc.data();
                        return `${itemData.name} - Small: ${itemData.prices?.Small ?? "N/A"}, Medium: ${itemData.prices?.Medium ?? "N/A"}, Large: ${itemData.prices?.Large ?? "N/A"}`;
                    });

                    return menu.join("\n");
                }

            case "find_items_by_category":
                {
                    if (!category) return "Please specify a category.";
                    const snapshot = await db.collectionGroup("items").where("category", "==", category).get();
                    if (snapshot.empty) {
                        return `No items found in category "${category}".`;
                    }

                    const items = snapshot.docs.map((doc) => {
                        const data = doc.data();
                        return `${data.name} - Small: ${data.prices?.Small ?? "N/A"}, Medium: ${data.prices?.Medium ?? "N/A"}, Large: ${data.prices?.Large ?? "N/A"}`;
                    });

                    return items.join("\n");
                }

            default:
                return "I'm not sure what you're looking for. Please clarify your request.";
        }
    } catch (error) {
        logger.error("Firestore Query Error:", error);
        throw new Error("Failed to fetch data from Firestore.");
    }
}
