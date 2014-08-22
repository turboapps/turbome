@ECHO OFF
ECHO Starting node.js...
CD c:\ghost
start "nodejs" npm start
ECHO Edit config.js to configure Ghost, if you haven't already.
ECHO ON