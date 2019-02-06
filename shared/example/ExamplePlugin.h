#ifndef EXAMPLEPLUGIN_H
#define EXAMPLEPLUGIN_H

#include <vtkUnstructuredGridAlgorithm.h>

class ExamplePlugin : public vtkUnstructuredGridAlgorithm
{
 public:
  vtkTypeMacro(ExamplePlugin,vtkUnstructuredGridAlgorithm);
  void PrintSelf(ostream& os, vtkIndent indent);

  static ExamplePlugin *New();

 protected:
  ExamplePlugin();
  ~ExamplePlugin();

  int RequestData(vtkInformation *, vtkInformationVector **, vtkInformationVector *);

 private:
  ExamplePlugin(const ExamplePlugin&);
  void operator=(const ExamplePlugin&);
};

#endif //EXAMPLEPLUGIN_H
