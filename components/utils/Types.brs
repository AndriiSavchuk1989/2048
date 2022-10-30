function isBoolean(obj as dynamic) as boolean
  return isValid(obj) and getInterface(obj, "ifBoolean") <> invalid
end function

function isArray(obj as dynamic) as boolean
  return isValid(obj) and getInterface(obj, "ifArray") <> invalid
end function

function isEmptyArray(obj as dynamic) as boolean
  return isArray(obj) and obj.count() = 0
end function

function isNotEmptyArray(obj as dynamic) as boolean
  return isArray(obj) and obj.count() > 0
end function

function isObject(obj as dynamic) as boolean
  return isValid(obj) and getInterface(obj, "ifAssociativeArray") <> invalid
end function

function isEmptyObject(obj as dynamic) as boolean
  return not isNotEmptyObject(obj)
end function

function isEqualObject(value as object, other as object) as boolean
  if isEmptyObject(value) or isEmptyObject(other) then return false
  if value.count() <> other.count() then return false

  for each item in value.items()
    otherItemValue = other.Lookup(item.key)
    if isInvalid(otherItemValue) or not isSameType(otherItemValue, item.value) or otherItemValue <> item.value then
      return false
    end if
  end for

  return true
end function

function isNotEmptyObject(obj as dynamic) as boolean
  return isObject(obj) and obj.count() > 0
end function

function isValid(obj as dynamic) as boolean
  return type(obj) <> "<uninitialized>" and obj <> invalid
end function

function isInvalid(obj as dynamic) as boolean
  return not isValid(obj)
end function

function isString(obj as dynamic) as boolean
  return isValid(obj) and getInterface(obj, "ifString") <> invalid
end function

function isNotEmptyString(obj as dynamic) as boolean
  return isString(obj) and Len(obj) > 0
end function

function isEmptyString(obj as dynamic) as boolean
  return isString(obj) and len(obj) = 0
end function

function isInteger(obj as dynamic) as boolean
  return isValid(obj) and getInterface(obj, "ifInt") <> invalid
end function

function isFloat(obj as dynamic) as boolean
  return isValid(obj) and getInterface(obj, "ifFloat") <> invalid
end function

function isLong(obj as dynamic) as boolean
  return isValid(obj) and getInterface(obj, "ifLongInt") <> invalid
end function

function isDouble(obj as dynamic) as boolean
  return isValid(obj) and getInterface(obj, "ifDouble") <> invalid
end function

function isNumber(obj as dynamic) as boolean
  return isFloat(obj) or isInteger(obj) or isLong(obj) or isDouble(obj)
end function

function isFunction(obj as dynamic) as boolean
  typeName = type(obj)

  return typeName = "Function" or typeName = "roFunction"
end function

function isNode(obj as dynamic) as boolean
  typeName = type(obj)

  return typeName = "SGNode" or typeName = "roSGNode"
end function

function isSubTypeOfNode(obj as dynamic, expectType as string) as boolean
  return isNode(obj) and obj.isSubType(expectType)
end function

function isSameType(obj1 as dynamic, obj2 as dynamic) as boolean
  type1 = (type(obj1)).Replace("ro", "")
  type2 = (type(obj2)).Replace("ro", "")

  return type1 = type2
end function

function isValidItemIndexes(indexes as object) as boolean
  return isNotEmptyArray(indexes) and isValid(indexes[0]) and isValid(indexes[1])
end function
