# prompts/completed/

Archivo historico de prompts ya procesados, con su respuesta al lado:

    completed/<code>/<YYYY-MM-DD>_<frente-slug>.md
    completed/<code>/<YYYY-MM-DD>_<frente-slug>_response.md

El orquestador mueve los pares (prompt + respuesta) desde `active/` e `inbox/`
una vez que la respuesta esta procesada y el state actualizado.
