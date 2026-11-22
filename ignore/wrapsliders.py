import re
with open('shaders/shaders.properties', 'r') as f: c = f.read()
items = ' '.join(re.findall(r"^\s*screen(?:\.(?!columns=)\w+)?=((?:.*\\\s*\n)*.*)", c, re.M)).replace('\\', '').split()
items = list(filter(lambda x: not re.fullmatch(r"<(?:empty|profile)>|\[.*?\]|\*", x), items))
sliders = re.search(r"sliders=((?:.*\\\s*\n)*.*)", c).group(1).replace('\\', '').split()
sliders = sorted(sliders, key=lambda s: items.index(s) if s in items else 2147483647)
out = 'sliders='
for s in sliders:
  line = out.split('\n')[-1]
  space = '' if line.endswith('=') else ' '
  if(len(line) + len(space) + len(s) + 2 > 94): out += ' \\\n' + s
  else: out += space + s
nc = re.sub(r"sliders=(?:.*\\\s*\n)*.*", out, c)
with open('shaders/shaders.properties', 'w') as f: f.write(nc)
