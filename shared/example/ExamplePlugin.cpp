#include "ExamplePlugin.h"

#include <vtkFieldData.h>
#include <vtkInformationVector.h>
#include <vtkInformation.h>
#include <vtkObjectFactory.h>
#include <vtkSmartPointer.h>
#include <vtkStreamingDemandDrivenPipeline.h>
#include <vtkIntArray.h>
#include <vtkUnstructuredGrid.h>

vtkStandardNewMacro(ExamplePlugin);

ExamplePlugin::ExamplePlugin()
{
  this->SetNumberOfInputPorts(1);
  this->SetNumberOfOutputPorts(1);
}

ExamplePlugin::~ExamplePlugin() = default;

int ExamplePlugin::RequestData(vtkInformation *vtkNotUsed(request),
                                       vtkInformationVector **inputVector,
                                       vtkInformationVector *outputVector)
{
  auto input = vtkUnstructuredGrid::GetData(inputVector[0],0);
  auto output = vtkUnstructuredGrid::GetData(outputVector,0);

  output->ShallowCopy(input);

  auto array = vtkSmartPointer<vtkIntArray>::New();
  array->SetNumberOfValues(1);
  array->SetValue(0, 42);
  array->SetName("Answer");
  output->GetFieldData()->AddArray(array);

  return 1;
}

void ExamplePlugin::PrintSelf(ostream& os, vtkIndent indent)
{
  this->Superclass::PrintSelf(os,indent);
}
