import gui_sdl: SdlGui;

import gfm.math: vec3f, vec4f;
import gfm.opengl: OpenGL, GLProgram, GLBuffer, VertexSpecification, GLVAO,
    glClearColor, glViewport, glClear,
    glDrawArrays, glDrawElements, glPointSize, 
    GL_DEPTH_BUFFER_BIT, GL_LINE_STRIP, GL_UNSIGNED_INT,
    GL_COLOR_BUFFER_BIT, GL_POINTS;
import gfm.sdl2: SDL_Event;
import vertex_provider: VertexProvider, testVertexProvider;

class MyGui : SdlGui
{
    private VertexProvider _vprovider;

    bool show_test_window = true;
    bool show_another_window = false;
    float[3] clear_color = [0.3f, 0.4f, 0.8f];

    this(int width, int height, ref VertexProvider vprovider)
    {
        import gui_imgui: imguiInit, igGetStyle;

        _vprovider = vprovider;
        super(width, height, _vprovider.vertices);
        
        imguiInit(window);
        with(igGetStyle())
        {
            FrameRounding = 4.0;
            GrabRounding  = 4.0;
        }
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
        foreach(vslice; _vprovider.slices)
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

    VertexProvider vprovider = testVertexProvider();

    auto gui = new MyGui(width, height, vprovider);
    auto max_value = vec3f(10000, 60000, 0);
    auto min_value = vec3f(0, 0, 0);
    gui.setMatrices(max_value, min_value);
    gui.run();
    gui.close();
    destroy(gui);

    return 0;
} 