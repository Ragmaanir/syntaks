
# macro flatten_tuple(arg)
#   {% if arg.class_name == "TupleLiteral" %}
#     {
#     {% for e,i in arg %}
#       flatten_tuple2({{e}}){% if i < arg.size-1 %},{% end %}
#     {% end %}
#     }
#   {% else %}
#     {{arg}}
#   {% end %}
# end
#
# macro flatten_tuple2(arg)
#   {% if arg.class_name == "TupleLiteral" %}
#     {% for e,i in arg %}
#       flatten_tuple2({{e}}){% if i < arg.size-1 %},{% end %}
#     {% end %}
#   {% else %}
#     {{arg}}
#   {% end %}
# end

# -----

# macro flatten_tuple(arg)
#   {% if arg.class_name == "TupleLiteral" %}
#     {
#     {% for e,i in arg %}
#       {% if e.class_name == "TupleLiteral" %}
#         {% for x,ii in e %}
#           flatten_tuple({{x}}){% if ii < e.size-1 %},{% end %}
#         {% end %}
#       {% else %}{{e}}{% end %}{% if i < arg.size-1 %},{% end %}
#     {% end %}
#     }
#   {% else %}
#     {{arg}}
#   {% end %}
# end
#
# macro flatten_tuple2(arg)
#   {% if arg.class_name == "TupleLiteral" %}
#     {% for e,i in arg %}
#       flatten_tuple2({{e}}){% if i < arg.size-1 %},{% end %}
#     {% end %}
#   {% else %}
#     {{arg}}
#   {% end %}
# end

# -----

# macro flatten_tuple(arg)
#   {% if arg.class_name == "TupleLiteral" %}
#     {% str = "[" %}
#     {% for e,i in arg %}
#       {% if e.class_name == "TupleLiteral" %}
#         {% str += "] + flatten_tuple(#{e.id}) + [" %}
#         {% str = str[0..-5] if i == arg.size - 1 %}
#         #{#% str = str[0..-2] if i == arg.size - 1 %}
#       {% else %}
#         {% str += "#{e}," %}
#         {% str += "]" if i == arg.size - 1 %}
#       {% end %}
#     {% end %}
#     {{str.id}}
#   {% else %}
#     {{arg}}
#   {% end %}
# end
#
# p flatten_tuple({1,2,{:g,{4}}})
# p typeof(flatten_tuple({1,2,{:g,{4}}}))


# macro flatten_tuple(arg)
#   [
#   {% for e,i in arg %}
#     {% if e.class_name == "TupleLiteral" %}
#       ] + flatten_tuple({{e}})
#       {% if i < arg.size - 1 %}
#         + [
#       {% end %}
#     {% else %}
#       {{e}},
#       {% if i == arg.size - 1 %}
#         ]
#       {% end %}
#     {% end %}
#   {% end %}
# end

# macro flatten_tuple(arg)
#   {% str = "[" %}
#   {% for e,i in arg %}
#     {% if e.class_name == "TupleLiteral" %}
#       {% str += "] + flatten_tuple(#{e})" %}
#       {% if i < arg.size - 1 %}
#         {% str << "+ [" %}
#       {% end %}
#     {% else %}
#       {% str += "#{e}" %}
#       {% str += "]" if i == arg.size - 1 %}
#     {% end %}
#   {% end %}
#
#   X = {{str.id}}
#   array_to_tuple(x)
# end
#
# macro array_to_tuple(arr)
#   {
#   {% for e in arr %}
#     {{e}}
#   {% end %}
#   }
# end

macro flatten_tuple(arg)
  {% str = "[" %}
  {% for e,i in arg %}
    {% if e.class_name == "TupleLiteral" %}
      {% str += ",*flatten_tuple(#{e})" %}
    {% else %}
      {% str += "#{e}" %}
    {% end %}
  {% end %}
  {% str += "]" %}

  {{str.id}}
end

puts flatten_tuple({1,{2,{3}}})
