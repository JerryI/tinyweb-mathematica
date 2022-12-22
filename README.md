## The power of symbolic computation meets web design


# Tiny HTTP webserver

* HTTP and WebSocket server
* GET, POST methods
* caching
* single thread


# Wolfram Script Pages
> *hypertext preprocessor built on top of Wolfram Kernel*

Embed Mathematica code into HTML/CSS/JS. It works similar to PHP or Mustache template engine

![three pics](./threepics.png)
```php
<?wsp Table[ ?> 
<?wsp Graphics3D[i[], ImageSize->Small] ?> 
<?wsp, {i, {Icosahedron, Octahedron, Tetrahedron}}] ?>
```
If you need to calculate something more complex, use Module, With, Block as usual. All variables can be global.

Built-in functions in a tiny JS framework allows to use the same syntax as in Mathematica. In the real demo text area is mirrored to all clients, and updates on every type using websockets.

![three pics](./mirror.gif)
```php
    <input id="webinput" type="textarea" value="Type something...">
    <script>
        const input = document.getElementById('webinput');
        input.addEventListener('input', updateValue);
        function updateValue(e) {
             socket.send(`UpdateInput["${input.value}"]`);
             console.log(`${input.value}`);
        };
        core.SetInput = function(args, env) {
            input.value = interpretate(args[0]);
        };
    </script>
```
On the Mathematica's side there is only one line
```mathematica
    UpdateInput[string_] := WebSocketBroadcast[server, SetInput[string], client]
```

# Usage
Import the recent packages
```mathematica
Import["https://raw.githubusercontent.com/JerryI/tinyweb-mathematica/master/Tinyweb/Tinyweb.wl"]
Import["https://raw.githubusercontent.com/JerryI/tinyweb-mathematica/master/WSP/WSP.wl"]
```
Create a folder in your notebook (or script) directory *public* for instance
```
--   yourproject.nb or yourscript.wls
--   public/
--   --   index.wsp
```
Then, put somehting in your *index.wsp*
```php
Hi! Your city is <?wsp CommonName /@ GeoNearest[Entity["City"], Here, 1] // First ?>
```

Run the command in the saved notebook to start the server locally
```mathematica
server = WEBServer["addr" -> "127.0.0.1:80",
"path" -> NotebookDirectory[] <> "public", "socket-close" -> True]

server // WEBServerStart
```
or inside the WolframScript
```mathematica
#!/usr/bin/env wolframscript

Import["https://raw.githubusercontent.com/JerryI/tinyweb-mathematica/master/Tinyweb/Tinyweb.wl"];
Import["https://raw.githubusercontent.com/JerryI/tinyweb-mathematica/master/WSP/WSP.wl"];

server = WEBServer["addr" -> "127.0.0.1:80", "path" -> "public", "socket-close" -> True];
server // WEBServerStart;
```

# Docs 
The live version is /examples/demo/public

https://jerryi.github.io/tinyweb-mathematica/
