# prompts/active/

Prompts en vuelo, uno por archivo, organizados por code ejecutor:

    active/<code>/<YYYY-MM-DD>_<sprint-slug>.md

El orquestador escribe aqui. Si usas listeners (ver `../../listeners/`), el solo
acto de crear el archivo dispara la ejecucion. Cuando el ejecutor responde en
`inbox/<code>/` y el orquestador procesa la respuesta, mueve el prompt (y su
respuesta) a `../completed/<code>/`.
