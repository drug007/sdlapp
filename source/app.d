import test_gui: TestGui;

import data_provider: testData, DataProvider;

int main(string[] args)
{
    int width = 1800;
    int height = 768;

    auto dprovider = DataProvider(testData);

    auto gui = new TestGui(width, height, dprovider);
    auto max_value = dprovider.maximum;
    auto min_value = dprovider.minimal;
    gui.setMatrices(max_value, min_value);
    gui.run();
    gui.close();
    destroy(gui);

    return 0;
} 