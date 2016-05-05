module test_gui;

import gfm.opengl: glClearColor, glViewport, glClear, GL_COLOR_BUFFER_BIT;
import gfm.sdl2: SDL_Event;

import base_gui: BaseGui;
import data_provider: testData, DataProvider;

private static auto timeToStringz(long timestamp)
{
    import std.datetime: SysTime;
    import std.string: toStringz;

    return timestamp.SysTime.toUTC.toISOExtString[$-9..$].toStringz;
}

class TestGui : BaseGui
{
    private
    {
        DataProvider _data_provider;

        bool show_test_window    = false;
        bool show_another_window = false;
        bool show_settings       = true;

        int max_point_counts = 2;

        float[3] clear_color = [0.3f, 0.4f, 0.8f];
    }

    this(int width, int height, ref DataProvider dprovider)
    {
        import imgui_helpers: imguiInit, igGetStyle;

        imguiInit(window);
        with(igGetStyle())
        {
            FrameRounding = 4.0;
            GrabRounding  = 4.0;
        }

        _data_provider = dprovider;
        super(width, height);
        setTimeWindow();
    }

    private void setTimeWindow()
    {
        _data_provider.setTimeWindow(long.min, _data_provider.timestamp_slider.current);
        _data_provider.setPointCount(max_point_counts);
        setVertexProvider(_data_provider.vertex_provider);
    }

    void close()
    {
        import imgui_helpers: shutdown;

        _data_provider.close();

        shutdown();
    }

    /// Set imgui internal state according to SDL event
    override void processImguiEvent(ref const(SDL_Event) event)
    {
        import imgui_helpers: processEvent;

        processEvent(event);
    }

    /// Override rendering to embed imgui
    override void draw()
    {
        import derelict.imgui.imgui: igText, igButton, igBegin, igEnd, igRender, igGetIO,
            igSliderFloat, igColorEdit3, igTreePop, igTreeNode, igSameLine, igSmallButton,
            ImGuiIO, igSetNextWindowSize, igSetNextWindowPos, igTreeNodePtr, igShowTestWindow,
            ImVec2, ImGuiSetCond_FirstUseEver, igSliderInt;
		import imgui_helpers: imguiNewFrame;
        
        ImGuiIO* io = igGetIO();

        imguiNewFrame(window);

        {
            igSetNextWindowSize(ImVec2(400,600), ImGuiSetCond_FirstUseEver);
            igBegin("Settings", &show_settings);
            auto old_value = max_point_counts;
            igSliderInt("Max point counts", &max_point_counts, 1, 32);
            if(old_value != max_point_counts)
            {
                _data_provider.setPointCount(max_point_counts);
            }

            with(_data_provider.timestamp_slider)
            {
                int curr_idx = cast(int) currIndex;
                int min = 0;
                int max = cast(int)(length)-1;
                igSliderInt("Timestamp", &curr_idx, min, max);
                if(curr_idx != currIndex)
                {
                    setIndex(curr_idx);
                    setTimeWindow();
                }
                igText("Min time");
                igSameLine();
                igText(timeByIndex(min).timeToStringz);
                igSameLine();
                igText("Current time");
                igSameLine();
                igText(current.timeToStringz);
                igSameLine();
                igText("Max time");
                igSameLine();
                igText(timeByIndex(max).timeToStringz);
            }
            igEnd();
        }

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