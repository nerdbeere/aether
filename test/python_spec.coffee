Aether = require '../aether'

describe "Python Test suite", ->
  describe "Basics", ->
    aether = new Aether language: "python"
    it "return 1000", ->
      code = """
      return 1000
      """
      aether.transpile(code)
      expect(aether.run()).toEqual 1000

    it "simple if", ->
      code = """
      if False: return 2000
      return 1000
      """
      aether.transpile(code)
      expect(aether.run()).toBe(1000)

    it "multiple elif", ->
      code = """
      x = 4
      if x == 2:
        x += 1
        return '2'
      elif x == 44564:
        x += 1
        return '44564'
      elif x == 4:
        x += 1
        return '4'
      """
      aether.transpile(code)
      expect(aether.run()).toBe('4')

    it "mathmetics order", ->
      code = """
      return (2*2 + 2/2 - 2*2/2)
      """
      aether.transpile(code)
      expect(aether.run()).toBe(3)

    it "fibonacci function", ->
      code = """
      def fib(n):
        if n < 2: return n
        else: return fib(n - 1) + fib(n - 2)
      chupacabra = fib(6)
      return chupacabra
      """
      aether.transpile(code)
      expect(aether.run()).toBe(8)

    it "for loop", ->
      code = """
      data = [4, 2, 65, 7]
      total = 0
      for d in data:
        total += d
      return total
      """
      aether.transpile(code)
      expect(aether.run()).toBe(78)

    it "bubble sort", ->
      code = """
      import random
      def createShuffled(n):
        r = n * 10 + 1
        shuffle = []
        for i in range(n):
          item = int(r * random.random())
          shuffle.append(item)
        return shuffle

      def bubbleSort(data):
        sorted = False
        while not sorted:
          sorted = True
          for i in range(len(data) - 1):
            if data[i] > data[i + 1]:
              t = data[i]
              data[i] = data[i + 1]
              data[i + 1] = t
              sorted = False
        return data

      def isSorted(data):
        for i in range(len(data) - 1):
          if data[i] > data[i + 1]:
            return False
        return True

      data = createShuffled(10)
      bubbleSort(data)
      return isSorted(data)
      """
      aether.transpile(code)
      expect(aether.run()).toBe(true)

    it "dictionary", ->
      code = """
      d = {'p1': 'prop1'}
      return d['p1']
      """
      aether.transpile(code)
      expect(aether.run()).toBe('prop1')

    it "class", ->
      code = """
      class MyClass:
        i = 123
        def __init__(self, i):
          self.i = i
        def f(self):
          return self.i
      x = MyClass(456)
      return x.f()
      """
      aether.transpile(code)
      expect(aether.run()).toEqual(456)

    it "L[0:2]", ->
      code = """
      L = [1, 45, 6, -9]
      return L[0:2]
      """
      aether.transpile(code)
      expect(aether.run()).toEqual([1, 45])

    it "L[f(2)::9 - (2 * 5)]", ->
      code = """
      def f(x):
        return x
      L = [0, 1, 2, 3, 4]
      return L[f(2)::9 - (2 * 5)]
      """
      aether.transpile(code)
      expect(aether.run()).toEqual([2, 1, 0])

    it "T[-1:-3:-1]", ->
      code = """
      T = (0, 1, 2, 3, 4)
      return T[-1:-3:-1]
      """
      aether.transpile(code)
      expect(aether.run()).toEqual([4, 3])

    it "[str(round(pi, i)) for i in range(1, 6)]", ->
      code = """
      pi = 3.1415926
      L = [str(round(pi, i)) for i in range(1, 6)]
      return L
      """
      aether.transpile(code)
      expect(aether.run()).toEqual(['3.1', '3.14', '3.142', '3.1416', '3.14159'])
      
    it "[(x*2, y) for x in range(4) if x > 1 for y in range(2)]", ->
      code = """
      L = [(x*2, y) for x in range(4) if x > 1 for y in range(2)]
      return L[1]
      """
      aether.transpile(code)
      expect(aether.run()).toEqual([4, 1])

  describe "Usage", ->
    it "self.doStuff via thisValue param", ->
      history = []
      log = (s) -> history.push s
      moveDown = () -> history.push 'moveDown'
      thisValue = {say: log, moveDown: moveDown}
      aetherOptions = {
        language: 'python'
      }
      aether = new Aether aetherOptions
      code = """
      self.moveDown()
      self.say('hello')
      """
      aether.transpile code
      method = aether.createMethod thisValue
      aether.run method
      expect(history).toEqual(['moveDown', 'hello'])

    it "Math is fun?", ->
      thisValue = {}
      aetherOptions = {
        language: 'python'
      }
      aether = new Aether aetherOptions
      code = """
      return Math.abs(-3) == abs(-3)
      """
      aether.transpile code
      method = aether.createMethod thisValue
      expect(aether.run(method)).toEqual(true)

    it "self.getItems", ->
      history = []
      getItems = () -> [{'pos':1}, {'pos':4}, {'pos':3}, {'pos':5}]
      move = (i) -> history.push i
      thisValue = {getItems: getItems, move: move}
      aetherOptions = {
        language: 'python'
      }
      aether = new Aether aetherOptions
      code = """
      items = self.getItems()
      for item in items:
        self.move(item['pos'])
      """
      aether.transpile code
      method = aether.createMethod thisValue
      aether.run method
      expect(history).toEqual([1, 4, 3, 5])

  describe "parseDammit! & Ranges", ->
    aether = new Aether language: "python"
    it "missing )", ->
      code = """
      def fn():
        return 45
      x = fn(
      return x
      """
      aether.transpile(code)
      expect(aether.problems.errors.length).toEqual(1)
      expect(/Unexpected token/.test(aether.problems.errors[0].message)).toBe(true)
      expect(aether.problems.errors[0].range).toEqual([ { ofs : 38, row : 2, col : 7 }, { ofs : 39, row : 2, col : 8 } ])
      result = aether.run()
      expect(result).toEqual(45)

    it "bad indent", ->
      code = """
      def fn():
        x = 45
          x += 5
        return x
      return fn()
      """
      aether.transpile(code)
      result = aether.run()
      expect(aether.problems.errors.length).toEqual(1)
      expect(/Unexpected indent/.test(aether.problems.errors[0].message)).toBe(true)
      expect(aether.problems.errors[0].range).toEqual([ { ofs : 33, row : 2, col : 2 }, { ofs : 35, row : 2, col : 4 } ])
      expect(result).toEqual(50)

    it "x() row 0", ->
      code = """x()"""
      aether.transpile(code)
      expect(aether.problems.errors.length).toEqual(1)
      expect(aether.problems.errors[0].message).toEqual("Missing `this.` keyword; should be `this.x`.")
      expect(aether.problems.errors[0].range).toEqual([ { ofs: 0, row: 0, col: 0 }, { ofs: 3, row: 0, col: 3 } ])

    it "x() row 1", ->
      code = """
      y = 5
      x()
      """
      aether.transpile(code)
      expect(aether.problems.errors.length).toEqual(1)
      expect(aether.problems.errors[0].message).toEqual("Missing `this.` keyword; should be `this.x`.")
      expect(aether.problems.errors[0].range).toEqual([ { ofs: 10, row: 1, col: 0 }, { ofs: 13, row: 1, col: 3 } ])

    it "x() row 3", ->
      code = """
      y = 5
      s = 'some other stuff'
      if y is 5:
        x()
      """
      aether.transpile(code)
      expect(aether.problems.errors.length).toEqual(1)
      expect(aether.problems.errors[0].message).toEqual("Missing `this.` keyword; should be `this.x`.")
      expect(aether.problems.errors[0].range).toEqual([ { ofs: 54, row: 3, col: 2 }, { ofs: 57, row: 3, col: 5 } ])

    it "incomplete string", ->
      code = """
      s = 'hi
      return s
      """
      aether.transpile(code)
      expect(aether.problems.errors.length).toEqual(1)
      expect(/Unterminated string constant/.test(aether.problems.errors[0].message)).toBe(true)
      expect(aether.problems.errors[0].range).toEqual([ { ofs : 4, row : 0, col : 4 }, { ofs : 7, row : 0, col : 7 } ])
      result = aether.run()
      expect(result).toEqual('hi')
