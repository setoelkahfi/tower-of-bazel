import axios from "axios";

let host = process.env.REACT_APP_SPLITFIRE_API_HOST;

const client = axios.create({
    baseURL: `https://${host}/api/v1/`,
    headers: {
        "Content-Type": "application/json",
    },
});

export default client;
