#!/bin/bash

echo 'STATUS 0
<p>This is a simple test module.</p>
<p style="font-style: italic">Hello, world!</p>
<p>Headers follow ...</p>
<pre>'

while read -t 1
do
	echo "$REPLY"
done

echo '</pre>'

