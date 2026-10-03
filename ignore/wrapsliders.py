import re
with open('shaders/shaders.properties', 'r') as f: c = f.read()
sliders = re.search(r"sliders=((?:.*\\\s*\n)*.*)", c).group(1).replace('\\', '').split()
out = 'sliders='
for s in sliders:
  line = out.split('\n')[-1]
  space = '' if line.endswith('=') else ' '
  if(len(line) + len(space) + len(s) + 2 > 94): out += ' \\\n' + s
  else: out += space + s
nc = re.sub(r"sliders=(?:.*\\\s*\n)*.*", out, c)
with open('shaders/shaders.properties', 'w') as f: f.write(nc)
