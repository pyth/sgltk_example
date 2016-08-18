#include <sgltk/app.h>
#include <sgltk/window.h>
#include <sgltk/mesh.h>
#include <sgltk/camera.h>
#include <sgltk/shader.h>

#ifdef __linux__
	#include <unistd.h>
#else
	#include <direct.h>
#endif //__linux__


#define RES_X 1024
#define RES_Y 754


class Win : public sgltk::Window {
	sgltk::Mesh *mesh;
	sgltk::Shader *shader;
	sgltk::Camera *cam;
public:
	Win(const char *title, int res_x, int res_y, int offset_x,
		int offset_y, int gl_maj, int gl_min, unsigned int flags);
	~Win();
	void handle_key_press(std::string key, bool pressed);
	void display();
};

Win::Win(const char *title, int res_x, int res_y, int offset_x, int offset_y, int gl_maj, int gl_min, unsigned int flags) :
	sgltk::Window(title, res_x, res_y, offset_x, offset_y, gl_maj, gl_min, flags) {

	//triangle vertex positions
	std::vector<glm::vec4> pos = {	glm::vec4(-5, -5, 0, 1),
					glm::vec4(5, -5, 0, 1),
					glm::vec4(0, 5, 0, 1)};
	//triangle vertex color values
	std::vector<glm::vec4> color = {glm::vec4(1, 0, 0, 1),
					glm::vec4(0, 1, 0, 1),
					glm::vec4(0, 0, 1, 1)};
	//triangle topology
	std::vector<unsigned short> ind = {0, 1, 2};

	//compile and link the shaders
	shader = new sgltk::Shader();
	shader->attach_file("vertex_shader.glsl", GL_VERTEX_SHADER);
	shader->attach_file("fragment_shader.glsl", GL_FRAGMENT_SHADER);
	shader->link();

	cam = new sgltk::Camera(glm::vec3(25, 25, 100), glm::vec3(0, 0, -1),
				glm::vec3(0, 1, 0),
				70.0f, RES_X, RES_Y, 0.1f, 800.0f);

	std::vector<glm::mat4> model_matrix(25);
	for(unsigned int i = 0; i < model_matrix.size(); i++) {
		model_matrix[i] = glm::translate(glm::vec3(i / 5 * 15, i % 5 * 15, 0));
	}

	//create the triangle mesh
	mesh = new sgltk::Mesh();
	int pos_buf = mesh->attach_vertex_buffer<glm::vec4>(&pos);
	int color_buf = mesh->attach_vertex_buffer<glm::vec4>(&color);
	int mat_buf = mesh->attach_vertex_buffer<glm::mat4>(&model_matrix);
	mesh->attach_index_buffer(&ind);
	mesh->setup_shader(shader);
	mesh->setup_camera(&cam->view_matrix, &cam->projection_matrix_persp);
	mesh->set_vertex_attribute(0, pos_buf, 4, GL_FLOAT, 0, 0);
	mesh->set_vertex_attribute(1, color_buf, 4, GL_FLOAT, 0, 0);

	for(int i = 0; i < 4; i++) {
		mesh->set_vertex_attribute(2 + i, mat_buf, 4, GL_FLOAT,
					sizeof(glm::mat4),
					(GLvoid *)(i * sizeof(glm::vec4)), 1);
	}

}

Win::~Win() {
	delete cam;
	delete shader;
	delete mesh;
}

void Win::handle_key_press(std::string key, bool pressed) {
	if(key == "Escape")
		stop();
}

void Win::display() {
	glClearColor(0, 0, 0, 1);
	glClearDepth(1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	mesh->draw_instanced(GL_TRIANGLES, 25);
}

int main(int argc, char **argv) {
	//change the current working directory to the location
	//of the executable
	std::string path(argv[0]);
	path = path.substr(0, path.find_last_of("\\/"));
	#ifdef __linux__
		chdir(path.c_str());
	#else
		_chdir(path.c_str());
	#endif //__linux__

	//initialize the library
	//this should be done prior to using any of the classes and
	//functions provided by sgltk
	sgltk::App::init();

	//setup the shader files location
	sgltk::Shader::add_path("../instanced_rendering/shaders");

	Win window("Instanced rendering",
					RES_X, RES_Y,
					100, 100,
					3, 3, 0);

	window.run();

	return 0;
}