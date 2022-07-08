Python Unittest Autospec
------------------------

```python
import unittest
import unittest.mock as mock

class Apple:
    def __init__(self):
        self._weight = 233

    def weight(self):
        print(self._weight)
        return self._weight

class TestAutospec(unittest.TestCase):
    def test_autospec(self):
        mocked_apple_class = mock.create_autospec(Apple)
        weight = mocked_apple_class().weight()
        mocked_apple_class().weight.assert_called_once_with()
        self.assertIsInstance(weight, mock.MagicMock)
```
