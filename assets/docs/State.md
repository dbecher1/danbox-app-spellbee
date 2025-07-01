# State and Order of Execution

A general description of the intended implementation for a FSM and flowchart for the program (that consisting of this app and the greater full-stack web application written in Elixir). This is a rough draft - not exact documentation or planning docs, but a little more than scratch notes.

This only concerns the interfacing that will happen with the full stack app.

Quick glossary for clarification:

 - Game client, or client
    
    The Love2D game

 - Web app, or app
    
    The Phoenix app. The client will only ever communicate directly with the backend via a Phoenix Channel

### 1. Pre-lobby

* The client sends a POST request to the /api/generate_code endpoint of the app, with the following schema:

    `{"id": string}`

    ...where `id` is the game client's UUID, generated on load and stored in the global variable GameID.

* (Optional but ideal, not implemented) app validates the request, likely via a secret in a header field

* App creates a database entry representing the creation of the lobby. On success, returns a 201 response code with the body:

    `{"code": string}`

    ...where `code` is the 4 letter uppercase room code. This should theoretically always success, however in the event that it does not, a 500 error code will be returned.

* The client then sends sends the app a request to establish a websocket*, more specifically create a Phoenix Channel. As per the [Phoenix documentation](https://hexdocs.pm/phoenix/writing_a_channels_client.html), this message (and all subsequent) will be in the form

    `[join_reference, message_reference, topic_name, event_name, payload]`

    ...where the fields are, respectively, `GameID`, the message number, `room:code`, where `code` is the variable described above, the event name, which will be unique per case (in this instance, `phx_join`), and the payload, which is essentially JSON. An example initial message could be:

        ["86bab4cf-1ad2-40e2-8b10-bf47cf034ee0", "0", "room:MGJN", "phx_join", {}]

    * Note: currently the socket is established within the network thread - maybe move this outside of the thread for easier error handling?

### 2. Lobby



### 3. Post lobby, pre Game

### 4. Game

### 5. Post-Game 1

### 6. Post-Game 2

---

The sequence of events is relatively linear in nature, with the exception of the user quitting the game to the lobby - in which case, the sequence of events will skip directly to step 6.