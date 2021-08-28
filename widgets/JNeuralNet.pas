unit JNeuralNet;

interface

type
  TMatrix = class
  protected
    function CreateArray: variant;
  public
    Constructor Create(dim1,dim2:integer); virtual;
    Procedure SetValue(i,j:integer;content:variant);
    Function GetValue(i,j:integer): Variant;
    function NrRows: Variant;
    Function NrColumns: Variant;
    FHandle: variant;
  end;

  Function Transpose(Matrixin:TMatrix): TMatrix;
  Function DotX(Matrix1,Matrix2:TMatrix): TMatrix;
  Function GetMaxIndex(row: integer; Matrix1: TMatrix): integer;

//
// feedforward general purpose neural network
//
type
  JW3Layer = record
  //public
    ActivationType : String;           // ['Sigmoid','Linear','Tanh']
    LayerType      : String;           // ['Input','Hidden','Output']
    MInput         : TMatrix;
    MOutput        : TMatrix;
    MWeights       : TMatrix;
    MError         : TMatrix;
    MDelta         : TMatrix;
    MSigmoid       : TMatrix;
  end;

  JW3TrainingRecord = record
  //public
		&inputs  : array of float;
		&outputs : array of float;
    &use     : string;
  end;

  JW3TrainingSet = record
  //public
    TrainingRecords : Array of JW3TrainingRecord;
    Epoch           : Integer := 0;
    NrTestRows      : Integer := 0;
  end;

  JW3NeuralNet = class
  public
    Layers         : array of JW3Layer;
    Layer          : JW3Layer;
    TrainingSet    : JW3TrainingSet;
    TrainingRecord : JW3TrainingRecord;
    LearningRate   : float;
    TrainingSplit  : float := 0;
    LoadArray      : variant;
    ResultA, ResultB, ResultC: TMatrix;
    constructor Create;
    Procedure AddLayer (NrNeurons: Integer; LayerType: String; ActivationType: String);
    Procedure SeedNetwork;
    Procedure LoadData(data: variant);
    Procedure AddTrainingData (Inputs: Array of float; Outputs: Array of float);
    Procedure Train;
    Procedure Test;
    function  VarToFloat(varia: variant): float;
  end;

implementation

{ JW3NeuralNet }

uses
  Globals, Types;

constructor JW3NeuralNet.Create;
begin
  inherited Create;

/*
â€¢ Random: Float Returns random number from interval [0, 1).
â€¢ RandomInt(range: Integer) Returns random number from interface [0, range).
â€¢ RandG(mean, stdDev: Float): Float Generates random numbers with normal distribution using Marsaglia-Bray algorithm.
â€¢ Randomize Sets the random generator seed to a random value.
â€¢ RandSeed: Integer Returns the random generator seed.
â€¢ SetRandSeed(seed: Integer) Sets the random generator seed to a given value.
*/

  SetRandSeed(1);   //alea error , see sms forum
  Randomize;

end;

Procedure JW3NeuralNet.AddLayer (NrNeurons: Integer; LayerType: String; ActivationType: String);
begin
//
  Layer.LayerType := LayerType;
  Layer.ActivationType := ActivationType;

  Layer.MInput   := TMatrix.Create(NrNeurons,1);
  Layer.MOutput  := TMatrix.Create(NrNeurons,1);
  Layer.MWeights := nil;
  Layer.MError   := nil;
  Layer.MDelta   := nil;
  Layer.MSigmoid := nil;

  Layers.Add(Layer);
end;

Procedure JW3NeuralNet.SeedNetwork;
begin
//
// seed network with random values
//
  For var i := 1 to Layers.Count -1 do begin
    var Temp1 := TMatrix.Create(Layers[i].MInput.NrRows,Layers[i-1].MOutput.NrRows);
    For var j := 0 to Temp1.NrRows -1 do begin
      For var k := 0 to Temp1.NrColumns -1 do begin
        Temp1.SetValue(j,k,-1+2*random);
      end;
    end;
    Layers[i].MWeights := Temp1;

    var Temp2 := TMatrix.Create(Layers[i].MInput.NrRows,Layers[i-1].MOutput.NrRows);
    Layers[i].MDelta := Temp2;
  end;
end;

Procedure JW3NeuralNet.LoadData(data: variant);
begin
  LoadArray := JSON.parse(data);

  for var i := 0 to LoadArray.TrainingRecords.length -1 do begin
    AddTrainingData([0],[0]);
  end;

  for var i := 0 to LoadArray.TrainingRecords.length -1 do begin
    for var j := 0 to LoadArray.TrainingRecords[i].&inputs.length -1 do
      TrainingSet.TrainingRecords[i].&inputs[j] := VarToFloat(LoadArray.TrainingRecords[i].&inputs[j]);
    for var k := 0 to Layers[Layers.Count-1].MOutput.NrRows do  //LoadArray.TrainingRecords[i].&outputs.length -1 do
      TrainingSet.TrainingRecords[i].&outputs[k] := VarToFloat(LoadArray.TrainingRecords[i].&outputs[k]);
  end;
end;

Procedure JW3NeuralNet.AddTrainingData (Inputs: Array of float; Outputs: Array of float);
begin
//
  TrainingRecord.&inputs  := Inputs;
  TrainingRecord.&outputs := Outputs;
  TrainingRecord.&use     := 'Train';
  TrainingSet.TrainingRecords.Add(TrainingRecord);
end;

Procedure JW3NeuralNet.Train;
begin
//
// split trainingdata randomly in a larger set for training and a smaller set for testing
//
  For var i := 0 to TrainingSet.TrainingRecords.Count - 1 do
    TrainingSet.TrainingRecords[i].&use := 'Train';

  var s1 : integer := 0;
  s1 := trunc(TrainingSet.TrainingRecords.Count * TrainingSplit / 100); //say s1 = 5% of 150 datarecords
  If s1 = 0 then s1 := 1;
  var s2 : integer := 0;
  var s3 : integer := 0;
  While S3 < S1 do begin                                                //s3 counts until > s1
    s2 := trunc(random * TrainingSet.TrainingRecords.Count);            //s2 is a random number between 0 and 150
    If TrainingSet.TrainingRecords[s2].&use = 'Train' then begin
      TrainingSet.TrainingRecords[s2].&use := 'Test';
      inc(s3);
    end;
  end;
  TrainingSet.NrTestRows := s3;
//
  Inc(TrainingSet.Epoch);
//
//  start training
//
  For var f := 0 to TrainingSet.TrainingRecords.Count - 1 do begin     // for each training record
    If TrainingSet.TrainingRecords[f].&use = 'Train' then begin
//
//  handle input layer
//
      For var q := 0 to Layers[0].MInput.NrRows -1 do begin
        Layers[0].MInput.SetValue(q,0,(TrainingSet.TrainingRecords[f].&inputs[q]/255*0.99)+0.01);
      end;
      Layers[0].MOutput := Layers[0].MInput;
//
//  handle subsequent layers
//
      For var p := 1 to Layers.Count -1 do begin
        Layers[p].MInput := DotX(Layers[p].MWeights,Layers[p-1].MOutput);
        For var i := 0 to Layers[p].MInput.NrRows -1 do begin
          Layers[p].MOutput.SetValue(i,0,(1/(1+power(exp(1.0),-Layers[p].MInput.GetValue(i,0)))));
        end;
      end;
//
//   calculate error = training output(s) - output(s) in last layer
//
      For var i := Layers.Count -1 to Layers.Count -1 do begin
        var Temp := TMatrix.Create(Layers[i].MOutput.NrRows,1);
        For var j := 0 to Temp.NrRows -1 do begin
          Temp.SetValue(j,0,(TrainingSet.TrainingRecords[f].&outputs[j]-Layers[i].MOutput.GetValue(j,0)));
        end;
        Layers[i].MError := Temp;
      end;
//
//  back-propagate error
//
      For var i := Layers.Count -2 downto 1 do begin          //could go down to 0 = input but not needed
        var Temp := TransPose(Layers[i+1].MWeights);
        Layers[i].MError := DotX(Temp,Layers[i+1].MError);
      end;
//
// adjust weights
//
      var Delta : float := 0;
      For var i := 1 to Layers.Count -1 do begin
        Layers[i].MSigmoid := Layers[i].MError;
        For var j := 0 to Layers[i].MSigmoid.NrRows -1 do begin
          Delta := LearningRate *
                   Layers[i].MError.GetValue(j,0) *
                   Layers[i].MOutput.GetValue(j,0) *
                   (1 - Layers[i].MOutput.GetValue(j,0));
          Layers[i].MSigmoid.SetValue(j,0,Delta);
        end;
        var Temp : TMatrix := TransPose(Layers[i-1].MOutput);
        Layers[i].MDelta := DotX(Layers[i].MSigmoid,Temp);

        For var p := 0 to Layers[i].MDelta.NrRows -1 do begin
          For var q := 0 to Layers[i].MDelta.NrColumns -1 do begin
            Layers[i].MWeights.SetValue(p,q,(Layers[i].MWeights.GetValue(p,q) + Layers[i].MDelta.GetValue(p,q)));
          end;
        end;

      end;
    end;         //of records to be used for training
  end;           //of training dataset
//
end;

Procedure JW3NeuralNet.Test;
begin
//
//  initialise 3 result matrices
//  ResultA = the input variables of the examples used in the test
//  ResultB = the output variables of the examples
//  ResultC = the outcome as computed by the network (ideally same as ResultB)
//
  ResultA := TMatrix.Create(TrainingSet.NrTestRows,TrainingSet.TrainingRecords[0].&inputs.count);
  ResultB := TMatrix.Create(TrainingSet.NrTestRows,TrainingSet.TrainingRecords[0].&outputs.count);
  ResultC := TMatrix.Create(TrainingSet.NrTestRows,Layers[Layers.Count -1].MOutput.NrRows);
  var CurrentTestRecord : integer := 0;

  For var f := 0 to TrainingSet.TrainingRecords.Count - 1 do begin     // for each training record
    If TrainingSet.TrainingRecords[f].&use = 'Test' then begin         // select 'Test' records
//
//  handle input layer
//
      For var q := 0 to Layers[0].MInput.NrRows -1 do begin
        Layers[0].MInput.SetValue(q,0,(TrainingSet.TrainingRecords[f].&inputs[q]/255*0.99)+0.01);
      end;
      Layers[0].MOutput := Layers[0].MInput;
//
//  handle subsequent layers
//
      For var p := 1 to Layers.Count -1 do begin
        Layers[p].MInput := DotX(Layers[p].MWeights,Layers[p-1].MOutput);
        For var i := 0 to Layers[p].MInput.NrRows -1 do begin
          Layers[p].MOutput.SetValue(i,0,(1/(1+power(exp(1.0),-Layers[p].MInput.GetValue(i,0)))));
        end;
      end;
//
//  fill the 3 result matrices
//
      for var z := 0 to TrainingSet.TrainingRecords[0].&inputs.count -1 do
        ResultA.SetValue(CurrentTestRecord,z,TrainingSet.TrainingRecords[f].&inputs[z]);
      for var z := 0 to TrainingSet.TrainingRecords[0].&outputs.count -1 do
        ResultB.SetValue(CurrentTestRecord,z,TrainingSet.TrainingRecords[f].&outputs[z]);
      for var z := 0 to Layers[Layers.Count -1].MOutput.NrRows -1 do
        ResultC.SetValue(CurrentTestRecord,z,Layers[Layers.Count -1].MOutput.GetValue(z,0));
      inc(CurrentTestRecord);

    end;   // of test records within training set
  end;     // of training set
//
end;

// helper function in lieu of VarToFloatDef which doesn't work
Function JW3NeuralNet.VarToFloat(varia: variant): float;
begin
  asm @result = @varia; end;
end;

//
// TMatrix (2D) ////////////////////////////////////////////////////////////////
//
Constructor TMatrix.Create(dim1,dim2:integer);
begin
  inherited Create;

  FHandle := CreateArray;
  for var i := 0 to dim1 -1 do begin
    FHandle[i] := CreateArray;
    for var j := 0 to dim2 -1 do begin
      FHandle[i][j] := 0;
    end;
  end;

  FHandle.rows := dim1;
  FHandle.columns := dim2;

end;

Procedure TMatrix.SetValue(i,j:integer; content: Variant);
begin
  FHandle[i][j] := content;
end;

Function TMatrix.GetValue(i,j: integer) : Variant;
begin
  result := FHandle[i][j];
end;

Function TMatrix.NrRows : Integer;
begin
  result := FHandle.rows;
end;

Function TMatrix.NrColumns : Variant;
begin
  result := FHandle.columns;
end;

Function Transpose(Matrixin:TMatrix) : TMatrix;
var
  MyTranspose : TMatrix;
begin
  MyTranspose := TMatrix.Create(Matrixin.NrColumns,Matrixin.NrRows);
  For var i := 0 to Matrixin.NrRows -1 do begin
    For var j := 0 to Matrixin.NrColumns -1 do begin
      MyTranspose.SetValue(j,i,Matrixin.GetValue(i,j));
    end;
  end;
  result := MyTranspose;
end;

Function DotX(Matrix1,Matrix2:TMatrix) : TMatrix;
var
  MyDotX : TMatrix;
begin
  MyDotX := TMatrix.Create(Matrix1.NrRows,Matrix2.NrColumns);
  For var i := 0 to Matrix1.NrRows -1 do begin
    For var j := 0 to Matrix2.NrColumns -1 do begin
      var sum: float := 0;
      For var k := 0 to Matrix1.NrColumns -1 do begin
        sum := sum + Matrix1.GetValue(i,k) * Matrix2.GetValue(k,j);
        MyDotX.SetValue(i,j,sum);
      end;
    end;
  end;
  result := MyDotX;
end;

function GetMaxIndex(row: integer; Matrix1: TMatrix): integer;
var
  maxvalue : float;
begin
  MaxValue := Matrix1.GetValue(row,0);
  Result := 0;
  For var i := 0 to Matrix1.NrColumns -1 do begin
    if Matrix1.GetValue(row, i) > MaxValue then begin
      MaxValue := Matrix1.GetValue(row, i);
      Result := i;
    end;
  end;
end;

function TMatrix.CreateArray: variant;
begin
  asm
    @result = new Array();
  end;
end;

end.


/*
  //For var i := 1 to Layers.Count -1 do begin
  //  console.log(JSON.Stringify(Layers[i].MWeights));
  //  console.log('=============================');
  //end;
*/

/*
Function GetMinValue(Matrix1: TMatrix): integer;
Function GetMaxValue(Matrix1: TMatrix): integer;

function GetMinValue(Matrix1: TMatrix): integer;
var
  minvalue : float;
begin
  MinValue := Matrix1.GetValue(0,0);
  Result := 0;
  For var i := 0 to Matrix1.NrRows -1 do begin
    if Matrix1.GetValue(i,0) < MinValue then begin
      MinValue := Matrix1.GetValue(i,0);
      Result := i;
    end;
  end;
end;

function GetMaxValue(Matrix1: TMatrix): integer;
var
  maxvalue : float;
begin
  MaxValue := Matrix1.GetValue(0,0);
  Result := 0;
  For var i := 0 to Matrix1.NrRows -1 do begin
    if Matrix1.GetValue(i,0) > MaxValue then begin
      MaxValue := Matrix1.GetValue(i,0);
      Result := i;
    end;
  end;
end;
*/

