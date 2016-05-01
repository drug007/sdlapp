import gui_sdl: SdlGui;

import gfm.math: vec3f, vec4f;
import gfm.opengl: OpenGL, GLProgram, GLBuffer, VertexSpecification, GLVAO,
    glClearColor, glViewport, glClear,
    glDrawArrays, glDrawElements, glPointSize, 
    GL_DEPTH_BUFFER_BIT, GL_LINE_STRIP, GL_UNSIGNED_INT,
    GL_COLOR_BUFFER_BIT, GL_POINTS;
import gfm.sdl2: SDL_Event;

struct Vertex
{
    vec3f position;
    vec4f color;
}

struct VertexSlice
{
    size_t start, length;
}

class MyGui : SdlGui!(Vertex)
{
    VertexSlice[] vslices;

    bool show_test_window = true;
    bool show_another_window = false;
    float[3] clear_color = [0.3f, 0.4f, 0.8f];

    this(int width, int height, Vertex[] vertices, VertexSlice[] vslices)
    {
        import gui_imgui: imguiInit, igGetStyle;

        super(width, height, vertices);
        
        imguiInit(window);
        with(igGetStyle())
        {
            FrameRounding = 4.0;
            GrabRounding  = 4.0;
        }

        this.vslices = vslices;
    }

    void close()
    {
        import gui_imgui: shutdown;

        shutdown();
    }

    /// Data rendering
    private void drawObjects()
    {
        glPointSize(5.);
        vao_points.bind();
        foreach(vslice; vslices)
        {
            glDrawElements(GL_LINE_STRIP, cast(int) (vslice
                .length), GL_UNSIGNED_INT, &indices[vslice.start]);
            glDrawArrays(GL_POINTS, cast(int) (vslice.start), cast(int) (vslice.length));
        }
        vao_points.unbind();
    }

    /// Set imgui internal state according to SDL event
    override void processImguiEvent(ref const(SDL_Event) event)
    {
        import gui_imgui: processEvent;

        processEvent(event);
    }

    /// Override rendering to embed imgui
    override void draw()
    {
        import derelict.imgui.imgui: igText, igButton, igBegin, igEnd, igRender, igGetIO,
            igSliderFloat, igColorEdit3, igTreePop, igTreeNode, igSameLine, igSmallButton,
            ImGuiIO, igSetNextWindowSize, igSetNextWindowPos, igTreeNodePtr, igShowTestWindow,
            ImVec2, ImGuiSetCond_FirstUseEver;
		import gui_imgui: imguiNewFrame;
        
        ImGuiIO* io = igGetIO();

        imguiNewFrame(window);

        // 1. Show a simple window
        // Tip: if we don't call ImGui::Begin()/ImGui::End() the widgets appears in a window automatically called "Debug"
        {
            static float f = 0.0f;
            igText("Hello, world!");
            igSliderFloat("float", &f, 0.0f, 1.0f);
            igColorEdit3("clear color", clear_color);
            if (igButton("Test Window")) show_test_window ^= 1;
            if (igButton("Another Window")) show_another_window ^= 1;
            igText("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / igGetIO().Framerate, igGetIO().Framerate);
        }
        
        // 2. Show another simple window, this time using an explicit Begin/End pair
        if (show_another_window)
        {
            igSetNextWindowSize(ImVec2(200,100), ImGuiSetCond_FirstUseEver);
            igBegin("Another Window", &show_another_window);
            igText("Hello");
            if (igTreeNode("Tree"))
            {
                for (size_t i = 0; i < 5; i++)
                {
                    if (igTreeNodePtr(cast(void*)i, "Child %d", i))
                    {
                        igText("blah blah");
                        igSameLine();
                        igSmallButton("print");
                        igTreePop();
                    }
                }
                igTreePop();
            }
            igEnd();
        }
        
        // 3. Show the ImGui test window. Most of the sample code is in ImGui::ShowTestWindow()
        if (show_test_window)
        {
            igSetNextWindowPos(ImVec2(650, 20), ImGuiSetCond_FirstUseEver);
            igShowTestWindow(&show_test_window);
        }

        // Rendering
        glViewport(0, 0, cast(int)io.DisplaySize.x, cast(int)io.DisplaySize.y);
        glClearColor(clear_color[0], clear_color[1], clear_color[2], 0);
        glClear(GL_COLOR_BUFFER_BIT);

        program.uniform("mvp_matrix").set(mvp_matrix);
        program.use();
        drawObjects();
        program.unuse();

        igRender();

        window.swapBuffers();
    }
}

int main(string[] args)
{
    int width = 1800;
    int height = 768;

    Vertex[] vertices = [
        Vertex(vec3f(-1092.77, 3109.23, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(-846.393, 5629.79, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(2241.08, 7544.54, 0),  vec4f(1, 0, 0, 1)),
        Vertex(vec3f(1627.69, 8812.62, 0),  vec4f(1, 0, 0, 1)),
        Vertex(vec3f(4280.15, 10970.9, 0),  vec4f(1, 0, 0, 1)),
        Vertex(vec3f(3847.78, 12459.6, 0),  vec4f(1, 0, 0, 1)),
        Vertex(vec3f(4780.92, 14114, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(5789.19, 17171.6, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(6646.42, 18283, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(3501.61, 20382.3, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(7708.97, 22914.5, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(9374.52, 23756.2, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(8531.2, 25360.4, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(9743.99, 28350.8, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(9980.87, 29713.3, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(10675.1, 31918.2, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(10033.1, 33354.2, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(8851.74, 36222.9, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(7580.04, 38375.4, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(5961.12, 39540.3, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(6105.15, 42402.8, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(6907.61, 44523.7, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(5299.64, 46581.2, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(5650.76, 49095.3, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(3428.36, 50385.9, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(3076.59, 52795, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(3923.46, 53858.1, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(2579.71, 57193.2, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(1362.94, 58802.6, 0), vec4f(1, 0, 0, 1)),
        Vertex(vec3f(-320.547, 3492.48, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(1006.87, 4856.31, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(1515.57, 6685.59, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(1866.04, 7764.19, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(2482.74, 10257.6, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(3671.67, 12920, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(3683.57, 14198.6, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(4642.62, 16148.2, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(5200.51, 17592, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(5731.06, 19887.8, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(6658.42, 22414.9, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(7113.78, 24003.3, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(7214.15, 25206.2, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(9053.16, 27670.1, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(9422.28, 30569.8, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(9353.74, 31954.2, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(9697.81, 34379.5, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(8104.14, 36093.2, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(7837.4, 37643.3, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(7018.64, 40498.6, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(6533.12, 41569.4, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(5520.14, 44868.3, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(3972.36, 47271.4, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(3558.43, 47289.3, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(4780.55, 50524.6, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(4264.73, 53695.2, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(1723.09, 54613.5, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(2344.24, 56259.6, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(1655.68, 59285.9, 0), vec4f(1, 1, 0.5, 1)),
        Vertex(vec3f(-1092.77, 3109.23, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(-673.1, 3396.83, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(-457.733, 5377.07, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(308.127, 5212.66, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(1576.62, 7242.36, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(1579.65, 7059.95, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(1905.68, 8800.04, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(1919.42, 8378.09, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(3401.79, 10538.3, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(2975.83, 10493.9, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(3713.82, 12340.5, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(3726.3, 12726.2, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(4555.62, 14283.9, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(4153.15, 14337.2, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(5273.19, 16618.2, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(4991.46, 16479.2, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(6120.96, 18244.9, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(5694.29, 18014.4, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(4899.97, 20062.1, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(5349.07, 20070.9, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(6831.04, 22356.5, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(6778.29, 22481.6, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(8378.42, 23982.7, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(7779.66, 24089, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(8457.44, 25588.5, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(7869.35, 25493.3, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(9108.68, 27785.8, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(9114.48, 27823.9, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(9849.69, 29632.4, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(9662.87, 30197.9, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(10411, 31929.6, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(9849.25, 32046.5, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(9643.15, 33642.1, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(9637.37, 34115.4, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(8946.54, 36110.9, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(8492.22, 36206.7, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(7738.12, 38232.8, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(7754.65, 38042.7, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(6559.87, 39733.2, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(6756.14, 40220.6, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(6132.63, 42253.4, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(6299.76, 42016, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(6305.67, 44211.6, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(5879.8, 44644.6, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(5291.7, 46554.6, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(4598.92, 47017.6, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(4826.83, 48998.2, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(4159.52, 48248.4, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(3495.92, 50258.9, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(4105.12, 50496.4, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(3292.84, 52587.4, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(3745.67, 53245.9, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(3536.55, 54493.8, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(2596.71, 54658.3, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(2290.19, 56867.5, 0), vec4f(0.6, 0.9, 0.5, 1)),
        Vertex(vec3f(2284.1, 56668.2, 0), vec4f(0.6, 0.9, 0.5, 1)),
    ];


    VertexSlice[] vslices = [
        VertexSlice(29, 16), 
        VertexSlice(58, 32), 
        VertexSlice( 0, 16),
    ];

    auto gui = new MyGui(width, height, vertices, vslices);
    auto max_value = vec3f(10000, 60000, 0);
    auto min_value = vec3f(0, 0, 0);
    gui.setMatrices(max_value, min_value);
    gui.run();
    gui.close();
    destroy(gui);

    return 0;
} 